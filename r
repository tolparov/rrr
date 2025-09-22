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
