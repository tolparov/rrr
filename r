package ru.sber.poirot.grs.registry.impl

import org.springframework.stereotype.Service
import ru.sber.poirot.grs.registry.RegistryRequest
import ru.sber.poirot.grs.registry.impl.FilterType.*
import ru.sber.poirot.grs.scheme.dto.SchemeDto
import java.time.LocalDate

@Service
class RegistryFilterProviderImpl : RegistryFilterProvider {

    override suspend fun filterItems(items: List<SchemeDto>, request: RegistryRequest?): List<SchemeDto> {
        return request?.let { applyFilters(items, it) } ?: items
    }

    private fun applyFilters(items: List<SchemeDto>, request: RegistryRequest): List<SchemeDto> {
        return items.asSequence()
            .filter { item -> filterByDates(item, request.fromDate, request.toDate) }
            .filter { item -> applyFieldFilters(item, request.filters) }
            .toList()
    }

    private fun filterByDates(item: SchemeDto, fromDate: LocalDate?, toDate: LocalDate?): Boolean {
        return (fromDate == null || !item.createdAt.toLocalDate().isBefore(fromDate)) &&
                (toDate == null || !item.createdAt.toLocalDate().isAfter(toDate))
    }

    private fun applyFieldFilters(item: SchemeDto, filters: List<RegistryRequest.Companion.RegistryFilter>): Boolean {
        if (filters.isEmpty()) return true

        val groupedFilters = filters.groupBy { FilterType.fromString(it.fieldName) }

        return groupedFilters.all { (type, filters) ->
            when (type) {
                NAME -> filters.any { it.fieldValue.equals(item.name, ignoreCase = true) }
                DESCRIPTION -> item.description?.let { desc ->
                    filters.any { it.fieldValue.equals(desc, ignoreCase = true) }
                } ?: false
                CURATOR -> filters.any { it.fieldValue.equals(item.curator, ignoreCase = true) }
                MANAGER -> item.manager?.let { exec ->
                    filters.any { it.fieldValue.equals(exec, ignoreCase = true) }
                } ?: false
                STATUS -> filters.any { it.fieldValue.equals(item.status, ignoreCase = true) }
                TAGS -> item.tags?.let { tags ->
                    filters.any { filter -> tags.any { tag -> tag.equals(filter.fieldValue, ignoreCase = true) } }
                } ?: false
                CREATED_AT -> filters.any { filter ->
                    item.createdAt.toLocalDate() == LocalDate.parse(filter.fieldValue)
                }
                UPDATED_AT -> filters.any { filter ->
                    item.updatedAt.toLocalDate() == LocalDate.parse(filter.fieldValue)
                }
            }
        }
    }
}createdAt/ updatedAt в таком формате подойдет? YYYY-MM-DD
или там прям минуты/часы обязательно в каком формате ожидает бэк сейчас ?package ru.sber.poirot.grs.scheme.dto

import java.time.LocalDateTime

data class SchemeDto(
    val id: Long,
    val name: String,
    val description: String?,
    val curator: String,
    val manager: String?,
    val supervision: Boolean?,
    val status: String,
    val reasonReturn: String?,
    val tags: List<String>? = null,
    val createdAt: LocalDateTime,
    val updatedAt: LocalDateTime,
    val isEditable: Boolean = false,
    val isDeletable: Boolean = false
)package ru.sber.poirot.grs.registry

import io.swagger.v3.oas.annotations.media.Schema
import ru.sber.poirot.grs.registry.impl.FilterType
import java.time.LocalDate

data class RegistryRequest(
    @Schema(description = "Изначальная дата для фильтрации")
    val fromDate: LocalDate,
    @Schema(description = "Конечная дата для фильтрации (включительно)")
    val toDate: LocalDate,
    @Schema(description = "Дополнительные фильтры")
    val filters: List<RegistryFilter> = emptyList(),
) {
    companion object {
        data class RegistryFilter(
            @Schema(description = "Название фильтра", implementation = FilterType::class)
            val fieldName: String,
            @Schema(description = "Значение фильтра")
            val fieldValue: String,
        )
    }
}
