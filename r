package ru.sber.poirot.focus.shared.contract.frauds

interface Checked {
    val blockName: String

    val affectedByDefault: Boolean?

    val isEmpty: Boolean
    val isNotEmpty: Boolean get() = !isEmpty
    val confirmedChecks: Map<Boolean, String>

    val notConfirmedChecks: Map<Boolean, String>

    fun errorConfirmed(): String? = errorFrom(true, confirmedChecks)

    fun errorNotConfirmed(): String? = errorFrom(false, notConfirmedChecks)

    private fun errorFrom(required: Boolean, errorProviders: Map<Boolean, String>): String? {
        val errors = buildList {
            errorProviders.forEach { (condition, error) ->
                if (condition) this.add(error)
            }
        }
        return when {
            errors.isEmpty() -> null
            errors.size == 1 -> "Поле \"${errors.single()}\" блока \"$blockName\" ${if (required) "должно" else "не должно"} быть заполнено"
            else -> errors.joinToString(
                ", ",
                "Поля ",
                " блока $blockName ${if (required) "должны" else "не должны"} быть заполнены"
            ) { "\"$it\"" }
        }
    }
}

const val AFFECTED_BY_DEFAULT = "Влияние на дефолт"
const val DATE = "Дата"
const val DATES = "Даты"
const val REPORT_TYPE = "Тип отчётности"
const val SIGN = "Признаки"
const val START_DATE = "Дата начала периода"
const val COMMENT = "Посредники" package ru.sber.poirot.focus.shared.contract.frauds

import java.time.LocalDate
import ru.sber.poirot.engine.model.api.monitoring.FakeReport as ApiFakeReport

data class FakeReportDoc(
    override val affectedByDefault: Boolean?,
    val affectedDate: LocalDate?,
) : Checked {
    override val blockName: String = "Фальсификация документов"

    override val isEmpty: Boolean =
        (affectedByDefault == null || affectedByDefault == false) &&
            affectedDate == null

    override val confirmedChecks: Map<Boolean, String> = mapOf(
        (affectedDate == null) to DATE,
    )

    override val notConfirmedChecks: Map<Boolean, String> = mapOf(
        (affectedByDefault == true) to AFFECTED_BY_DEFAULT,
        (affectedDate != null) to DATE,
    )

    companion object {
        fun ApiFakeReport.toFakeReportDocModel(): FakeReportDoc =
            FakeReportDoc(
                affectedDate = affectedByDocDate,
                affectedByDefault = affectedByDocDefault,
            )
    }
}package ru.sber.poirot.focus.shared.contract.frauds

import java.time.LocalDate
import ru.sber.poirot.engine.model.api.monitoring.FakeReport as ApiFakeReport

data class FakeReport(
    val type: Int?,
    override val affectedByDefault: Boolean?,
    val affectedDates: List<LocalDate>,
) : Checked {
    override val blockName: String = "Фальсификация отчётности"

    override val isEmpty: Boolean = (type == null || type == 0) &&
        (affectedByDefault == null || affectedByDefault == false) &&
        affectedDates.isEmpty()

    override val confirmedChecks: Map<Boolean, String> = mapOf(
        (affectedDates.isEmpty()) to DATES,
        (type == null) to REPORT_TYPE,
    )

    override val notConfirmedChecks: Map<Boolean, String> = mapOf(
        (affectedByDefault == true) to AFFECTED_BY_DEFAULT,
        (affectedDates.isNotEmpty()) to DATES,
        (type != null && type != 0) to REPORT_TYPE,
    )

    companion object {
        fun ApiFakeReport.toFakeReportModel(): FakeReport =
            FakeReport(
                affectedByDefault = affectedByDefault,
                type = type,
                affectedDates = affectedDates.map { it.affectedDate },
            )
    }
} вот примеры сделай чтоб это проверка коректно работала
