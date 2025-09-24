class RequestFilter(
    val types: List<ProcessType>,
    private val filtersInfo: Map<FieldName, List<String>>,
) {
    fun check(record: BasketRecord): Boolean {
        // если фильтруем по типу, то сравниваем с record.type
        if (types.isNotEmpty() && types.none { it.type == record.type }) {
            return false
        }

        return filtersInfo.all { (fieldName, fieldValues) ->
            record.filterBy(fieldName, fieldValues)
        }
    }

    private fun BasketRecord.filterBy(fieldName: FieldName, fieldValues: List<String>): Boolean =
        when (fieldName) {
            FieldName.TYPE -> true // тип мы уже проверили отдельно
            FieldName.NAME -> fieldValues.any { fieldValue ->
                record.name?.let { name -> fieldValue.lowercase() in name.lowercase() } ?: false
            }
            FieldName.APP_ID -> record.appId in fieldValues
            FieldName.INN -> record.inn in fieldValues
            FieldName.STATUS -> record.status.lowercase() in fieldValues.map { it.lowercase() }
        }

    companion object {
        fun filterFrom(request: RecordsRequest): RequestFilter {
            fun List<RecordsRequest.FieldFilter>.toTypes(): List<ProcessType> =
                if (isEmpty()) ProcessType.entries
                else map { ProcessType.byTypeName(it.fieldValue) }.distinct()

            fun List<RecordsRequest.FieldFilter>.toFiltersInfo(): Map<FieldName, List<String>> =
                groupBy { it.fieldName }
                    .mapValues { (_, filters) -> filters.map { it.fieldValue } }

            val (typeFilters, otherFilters) = request.filters.partition { it.fieldName == FieldName.TYPE }

            return RequestFilter(typeFilters.toTypes(), otherFilters.toFiltersInfo())
        }
    }
}
