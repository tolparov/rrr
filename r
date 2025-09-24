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

        val actualTypesForLoader = requestFilter.types.filterNot { it == ProcessType.MON_KSB }

        val (successResponses, errorResponses) = basketLoaders
            .filter { it.type in actualTypesForLoader }
            .loadRecords(request)
            .optimizedPartition { it.success }

        val records = successResponses.toRecords()
            .filter { requestFilter.check(it.record) }
            .map { record ->
                val processType = (record.record.metadata as? Map<*, *>)?.get("processType")
                val type = when (processType) {
                    11 -> "MON" // назначаем виртуальный тип для записи FM
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
} давай сделай when mon прям сразу при получение из лоудера 
