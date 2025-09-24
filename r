package ru.sber.poirot.basket.api.impl

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
}package ru.sber.poirot.basket.api.impl

enum class ProcessType(val type: String, val codeName: String, val serviceName: String) {
    DER("DER", "ДЭР", "der"),
    FOCUS_MONITORING("FM", "Фокусный мониторинг", "focus-monitoring"),
    ARBITRATION("ARB", "Арбитраж", "arbitration"),
    DEVIATION("DEV", "Отклонения", "deviation"),
    PCF_MONITORING("PCF", "РПФ Мониторинг", "pcf-monitoring"),
    GROUPS_RELATED_SCAMS("GRS", "Группы связанных мошенников", "groups-related-scams");

    companion object {
        fun byTypeName(typeName: String): ProcessType = entries.firstOrNull { it.type == typeName }
            ?: throw IllegalArgumentException("no found processType: $typeName")
    }
}package ru.sber.poirot.basket.api.impl

import ru.sber.poirot.basket.api.model.FieldName
import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.common.UnifiedRecord

class RequestFilter(
    val types: List<ProcessType>,
    private val filtersInfo: Map<FieldName, List<String>>,
) {
    fun check(record: UnifiedRecord) = filtersInfo
        .all { (fieldName, fieldValues) -> record.filterBy(fieldName, fieldValues) }

    private fun UnifiedRecord.filterBy(fieldName: FieldName, fieldValues: List<String>): Boolean =
        when (fieldName) {
            FieldName.TYPE -> true
            FieldName.NAME -> fieldValues.any { fieldValue ->
                name?.let { name -> fieldValue.lowercase() in name.lowercase() } ?: false
            }

            FieldName.APP_ID -> appId in fieldValues
            FieldName.INN -> inn in fieldValues
            FieldName.STATUS -> status.lowercase() in fieldValues.map { it.lowercase() }
        }

    companion object {
        fun filterFrom(request: RecordsRequest): RequestFilter {
            fun List<RecordsRequest.FieldFilter>.toTypes(): List<ProcessType> = when {
                isEmpty() -> ProcessType.entries
                else -> map { ProcessType.byTypeName(it.fieldValue) }.distinct()
            }

            fun List<RecordsRequest.FieldFilter>.toFiltersInfo(): Map<FieldName, List<String>> =
                groupBy { it.fieldName }.mapValues { (_, filters) -> filters.map { it.fieldValue } }

            val (typeFilters, otherFilters) = request.filters.partition { it.fieldName == FieldName.TYPE }

            return RequestFilter(typeFilters.toTypes(), otherFilters.toFiltersInfo())
        }
    }
}
package ru.sber.poirot.basket.api

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
}package ru.sber.poirot.basket.api.model

import java.time.LocalDate

class RecordsRequest(
    val fromDate: LocalDate,
    val toDate: LocalDate,
    val filters: List<FieldFilter>,
) {
    class FieldFilter(
        val fieldName: FieldName,
        val fieldValue: String,
    )
}
package ru.sber.poirot.basket.api.model

import com.fasterxml.jackson.annotation.JsonProperty

enum class FieldName {
    @JsonProperty("type") TYPE,
    @JsonProperty("name") NAME,
    @JsonProperty("appId") APP_ID,
    @JsonProperty("inn") INN,
    @JsonProperty("status") STATUS;
}  package ru.sber.poirot.basket.api.impl

import ru.sber.poirot.basket.api.model.RecordsRequest
import ru.sber.poirot.basket.common.SourceResponse

interface BasketLoader {
    val type: ProcessType

    suspend fun getRecords(recordsRequest: RecordsRequest): SourceResponse
}  package ru.sber.poirot.basket.common

class SourceResponse(
    val records: List<BasketRecord> = emptyList(),
    val errorMessage: String? = null,
) {
    val success: Boolean = records.isNotEmpty()

    companion object {
        fun success(records: List<BasketRecord>) = SourceResponse(records = records)

        fun error(error: String) = SourceResponse(errorMessage = error)
    }
}

fun List<SourceResponse>.toRecords(): List<BasketRecord> = flatMap { it.records }

fun List<SourceResponse>.toErrorMessages(): List<String> = mapNotNull { it.errorMessage }package ru.sber.poirot.basket.common

import com.fasterxml.jackson.annotation.JsonUnwrapped
import ru.sber.poirot.common.UnifiedRecord
import java.time.LocalDateTime

data class BasketRecord(
    val type: String,
    val sla: Sla?,
    @JsonUnwrapped
    val record: UnifiedRecord
) {
    data class Sla(
        val initialDeadline: LocalDateTime?,
        val prolongedDeadline: LocalDateTime?,
        val prolongationReason: String?,
    )
} моя задача добавить новый типо MON в енам чтоб с ним также работала вся логика отдельный фильтр по типу и тд но при load нам не нужно тянуть отдельно записи из mon а нужно подтянуть записи из фм и если процесс тайп 11 то мы присваиваем тип MON и наче оставляем FOCUC  мне нужно чтоб фильтрация работала абсолютно корректно
