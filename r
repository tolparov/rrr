package ru.sber.poirot.common

import ru.sber.poirot.dpa.dto.HistorySla
import java.time.LocalDateTime

data class UnifiedRecord(
    val date: LocalDateTime,
    val name: String?,
    val appId: String?,
    val inn: String?,
    val status: String,
    val id: String,
    val metadata: Any? = null,
    val sla: Sla? = null,
) {
    data class Sla(
        val initialDeadline: LocalDateTime?,
        val prolongedDeadline: LocalDateTime?,
        val prolongationReason: String?,
    ) {
        companion object {
            fun HistorySla.toUnifiedSla(): Sla =
                Sla(
                    initialDeadline = previousSla,
                    prolongedDeadline = sla,
                    prolongationReason = changeReason?.description,
                )
        }
    }
}package ru.sber.poirot.focus.unified.common.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.common.UnifiedRecord
import ru.sber.poirot.engine.dsl.Filter
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.focusMonitoringRecord
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.utils.withMeasurement
import ru.sber.utils.logger

@Repository
class DslUnifiedRecordsDao : UnifiedRecordsDao {
    private val log = logger()

    override suspend fun findUnifiedRecords(filter: Filter): List<UnifiedRecord> =
        withMeasurement(message = "Found unified records", logger = log, constraintInMs = 100) {
            (findAll(
                entity = focusMonitoringRecord,
                batch = false,
            ) fetchFields {
                listOf(id, dateInitiation, dateCreate, name, inn, status)
            } where {
                filter
            }).map { record ->
                UnifiedRecord(
                    date = record.dateInitiation ?: record.dateCreate,
                    name = record.name,
                    appId = null,
                    inn = record.inn,
                    status = MonitoringStatus.getStatusById(record.status)?.status ?: "Статус не найден",
                    id = record.id.toString()
                )
            }
        }
}package ru.sber.poirot.focus.unified.basket

import org.springframework.stereotype.Service
import ru.sber.poirot.basket.BasketProviderRequest
import ru.sber.poirot.basket.UnifiedBasketProvider
import ru.sber.poirot.common.UnifiedRecord
import ru.sber.poirot.dpa.sla.SlaInfoProvider
import ru.sber.poirot.engine.dsl.Filter
import ru.sber.poirot.focus.unified.basket.filter.FilterBuilder
import ru.sber.poirot.focus.unified.common.dao.UnifiedRecordsDao
import ru.sber.poirot.focus.unified.common.withSlas
import ru.sber.poirot.process.shared.TaskId

@Service
class FocusMonitoringBasketProvider(
    private val filterBuilder: FilterBuilder,
    private val recordsDao: UnifiedRecordsDao,
    private val slaInfoProvider: SlaInfoProvider,
) : UnifiedBasketProvider {
    override suspend fun getBasketRecords(request: BasketProviderRequest): List<UnifiedRecord> {
        val filter: Filter = filterBuilder.build(request)
        val records = recordsDao.findUnifiedRecords(filter)
        return records.map { TaskId(it.id) }.distinct()
            .let { slaInfoProvider.getHistorySlas(it) }
            .let { records.withSlas(it) }
    }
}package ru.sber.poirot.basket

import org.springframework.beans.factory.annotation.Value
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController
import ru.sber.poirot.audit.AuditClient
import ru.sber.poirot.common.UnifiedRecord

@RestController
class BasketProviderController(
    private val auditClient: AuditClient,
    private val basketProvider: UnifiedBasketProvider,
    @Value("\${spring.application.name}")
    private val serviceName: String,
) {

    @PostMapping("/internal/basket/records")
    suspend fun getBasketRecords(@RequestBody request: BasketProviderRequest): List<UnifiedRecord> =
        auditClient.audit(event = "${serviceName.uppercase()}_RECORDS_FETCHED_FOR_UNIFIED_BASKET", details = "request: $request") {
            basketProvider.getBasketRecords(request)
        }
}package ru.sber.poirot.basket.api.impl.loaders

import ru.sber.poirot.CurrentUser
import ru.sber.poirot.basket.BasketProviderRequest
import ru.sber.poirot.basket.api.impl.BasketLoader
import ru.sber.poirot.basket.api.impl.ProcessType
import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.basket.common.SourceResponse
import ru.sber.poirot.basket.common.sources.UnifiedSource
import ru.sber.poirot.common.UnifiedRole

class BasketLoaderImpl(
    private val currentUser: CurrentUser,
    private val roleMap: Map<String, UnifiedRole>,
    private val unifiedSource: UnifiedSource,
) : BasketLoader {
    override val type: ProcessType = unifiedSource.type

    override suspend fun getRecords(recordsRequest: RecordsRequest): SourceResponse {
        val request = recordsRequest.withUserInfo()
        return unifiedSource.fetch("/internal/basket/records", request)
    }

    private suspend fun RecordsRequest.withUserInfo(): BasketProviderRequest =
        BasketProviderRequest(
            fromDate = fromDate,
            toDate = toDate,
            roles = getRoles(),
            userName = currentUser.userName(),
        )

    private suspend fun getRoles(): List<UnifiedRole> =
        buildList {
            roleMap.forEach { (key, value) ->
                if (currentUser.hasPermission(key)) add(value)
            }
        }.distinct()
}package ru.sber.poirot.basket.api.impl

import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import org.springframework.stereotype.Service
import ru.sber.poirot.basket.api.UnifiedBasket
import ru.sber.poirot.basket.api.impl.RequestFilter.Companion.filterFrom
import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.basket.common.RecordsResponse
import ru.sber.poirot.basket.common.SourceResponse
import ru.sber.poirot.basket.common.toErrorMessages
import ru.sber.poirot.basket.common.toRecords
import ru.sber.utils.optimizedPartition

@Service
class UnifiedBasketImpl(
    private val basketLoaders: List<BasketLoader>,
) : UnifiedBasket {
    override suspend fun loadRecords(request: RecordsRequest): RecordsResponse {
        val requestFilter = filterFrom(request)

        val (successResponses, errorResponses) = basketLoaders
            .filter { it.type in requestFilter.types }
            .loadRecords(request)
            .optimizedPartition { it.success }

        val records = successResponses.toRecords().filter { requestFilter.check(it.record) }
        return RecordsResponse(
            records = records,
            warningMessages = errorResponses.toErrorMessages()
        )
    }

    private suspend fun List<BasketLoader>.loadRecords(request: RecordsRequest): List<SourceResponse> = coroutineScope {
        map { loader -> async { loader.getRecords(request) } }.awaitAll()
    }
}package ru.sber.poirot.basket.api

import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import ru.sber.permissions.frontback.HAS_UNIFIED_BASKET
import ru.sber.poirot.audit.AuditClient
import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.basket.common.RecordsResponse
import ru.sber.utils.withDefaultDispatcher

@RestController
@RequestMapping("/api")
class BasketController(
    private val unifiedBasket: UnifiedBasket,
    private val auditClient: AuditClient,
) {
    @PostMapping("/records")
    @PreAuthorize(HAS_UNIFIED_BASKET)
    suspend fun getRecords(@RequestBody request: RecordsRequest): RecordsResponse =
        withDefaultDispatcher {
            auditClient.audit(event = "UNIFIED_BASKET_ITEMS_FETCHED") {
                unifiedBasket.loadRecords(request)
            }
        }
}package ru.sber.poirot.basket.api.impl

enum class ProcessType(val type: String, val codeName: String, val serviceName: String) {
    DER("DER", "ДЭР", "der"),
    FOCUS_MONITORING("FM", "Фокусный мониторинг", "focus-monitoring"),
    ARBITRATION("ARB", "Арбитраж", "arbitration"),
    DEVIATION("DEV", "Отклонения", "deviation"),
    PCF_MONITORING("PCF", "РПФ Мониторинг", "pcf-monitoring"),
    MON_KSB("MON", "Мониторинг КСБ", "focus-monitoring");

    companion object {
        fun byTypeName(typeName: String): ProcessType = entries.firstOrNull { it.type == typeName }
            ?: throw IllegalArgumentException("no found processType: $typeName")
    }
} так как я делаю доработку в одном сервисе то для нового процесса я указал focus-monitoring и получается что происходит два запроса и записи дублируются я хотел попробовать добавить флаг в поле metadata чтоб вызывать сервис один раз и чтоб записи были двух разных процессов получается когда id 11 то процесс MON
