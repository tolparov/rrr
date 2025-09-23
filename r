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

        val records = successResponses.toRecords()
            .filter { requestFilter.check(it.record) }
            .map { record ->
                val processType = (record.record.metadata as? Map<*, *>)?.get("processType")
                val type = when {
                    processType == 11 -> "MON"
                    else -> record.type
                }
                record.copy(type = type)
            }

        return RecordsResponse(
            records = records,
            warningMessages = errorResponses.toErrorMessages()
        )
    }

    private suspend fun List<BasketLoader>.loadRecords(request: RecordsRequest): List<SourceResponse> = coroutineScope {
        map { loader -> async { loader.getRecords(request) } }.awaitAll()
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
package ru.sber.poirot.basket.api.impl

enum class ProcessType(val type: String, val codeName: String, val serviceName: String) {
    DER("DER", "ДЭР", "der"),
    FOCUS_MONITORING("FM", "Фокусный мониторинг", "focus-monitoring"),
    ARBITRATION("ARB", "Арбитраж", "arbitration"),
    DEVIATION("DEV", "Отклонения", "deviation"),
    PCF_MONITORING("PCF", "РПФ Мониторинг", "pcf-monitoring");

    companion object {
        fun byTypeName(typeName: String): ProcessType = entries.firstOrNull { it.type == typeName }
            ?: throw IllegalArgumentException("no found processType: $typeName")
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
 вообщем помнишь мы добавили новый процесс хардкодом "MON" потому что это процесс в рамках одного сервиса так вот нжуно чтоб для него работало фильтрация по типу процесса если с ui приходит фильтр
