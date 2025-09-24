@Service
class UnifiedBasketImpl(
    private val basketLoaders: List<BasketLoader>,
) : UnifiedBasket {
    override suspend fun loadRecords(request: RecordsRequest): RecordsResponse {
        val requestFilter = filterFrom(request)

        // Если в фильтрах есть MON → тянем FM, чтобы оттуда достать MON-записи
        val effectiveTypes = requestFilter.types.map {
            if (it == ProcessType.MON) ProcessType.FOCUS_MONITORING else it
        }

        val (successResponses, errorResponses) = basketLoaders
            .filter { it.type in effectiveTypes }
            .loadRecords(request)
            .optimizedPartition { it.success }

        val records = successResponses.toRecords()
            .map { record ->
                val processType = (record.record.metadata as? Map<*, *>)?.get("processType")
                val type = when {
                    record.type == ProcessType.FOCUS_MONITORING.type && processType == 11 -> ProcessType.MON.type
                    else -> record.type
                }
                record.copy(type = type)
            }
            // 👇 фильтрация выполняется уже по подменённому типу
            .filter { requestFilter.check(it.record.copy(type = it.type)) }

        return RecordsResponse(
            records = records,
            warningMessages = errorResponses.toErrorMessages()
        )
    }

    private suspend fun List<BasketLoader>.loadRecords(request: RecordsRequest): List<SourceResponse> = coroutineScope {
        map { loader -> async { loader.getRecords(request) } }.awaitAll()
    }
}
