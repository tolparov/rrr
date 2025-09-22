package ru.sber.poirot.basket.common

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


        val records = successResponses
            .toRecords()
            .distinctBy { rec -> rec.record.id to (rec.record.metadata as? Map<*, *>)?.get("processType") }
            .filter { requestFilter.check(it.record) }
        return RecordsResponse(
            records = records,
            warningMessages = errorResponses.toErrorMessages()
        )
    }

    private suspend fun List<BasketLoader>.loadRecords(request: RecordsRequest): List<SourceResponse> = coroutineScope {
        map { loader -> async { loader.getRecords(request) } }.awaitAll()
    }
}
package ru.sber.poirot.basket.api.impl

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
package ru.sber.poirot.basket.api.model

import com.fasterxml.jackson.annotation.JsonProperty

enum class FieldName {
    @JsonProperty("type") TYPE,
    @JsonProperty("name") NAME,
    @JsonProperty("appId") APP_ID,
    @JsonProperty("inn") INN,
    @JsonProperty("status") STATUS;
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
                listOf(id, dateInitiation, dateCreate, name, inn, status, processType)
            } where {
                filter
            }).map { record ->
                UnifiedRecord(
                    date = record.dateInitiation ?: record.dateCreate,
                    name = record.name,
                    appId = null,
                    inn = record.inn,
                    status = MonitoringStatus.getStatusById(record.status)?.status ?: "Статус не найден",
                    id = record.id.toString(),
                    metadata = mapOf("processType" to if (record.processType == 11) "MON" else "FM")
                )
            }
        }
}
