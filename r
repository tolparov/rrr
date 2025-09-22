package ru.sber.poirot.focus.shared.contract

import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.contract.FieldConstraints.LONG_TEXT_LIMIT
import ru.sber.poirot.focus.shared.contract.FieldConstraints.MEDIUM_TEXT_LIMIT
import ru.sber.poirot.focus.shared.contract.FieldConstraints.STANDARD_TEXT_LIMIT
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.INCORRECT_LENGTH

object FieldConstraints {
    const val STANDARD_TEXT_LIMIT = 4000
    const val LONG_TEXT_LIMIT = 32000
    const val MEDIUM_TEXT_LIMIT = 9000
}

fun ChangeRequest.checkFields(confirmedAllEmptyError: FocusErrorCode, validationFailedError: FocusErrorCode) {
    validateTextFields()

    val providers = listOf(fakeReport, bankruptcy, capitalOutflow, fakeReportDoc)
    when {
        fraudSigns.confirmedFraud?.value == true -> {
            if (providers.all { it.isEmpty }) throw FrontException(confirmedAllEmptyError)
            val errors = providers.filterNot { it.isEmpty }.mapNotNull { it.errorConfirmed() }
            errors.throwIfEmpty(validationFailedError)
        }

        else -> {
            val errors = providers.mapNotNull { it.errorNotConfirmed() }
            errors.throwIfEmpty(validationFailedError)
        }
    }
}

fun ChangeRequest.validateTextFields() {
    val fieldChecks = listOf(
        Triple({ pb.externalFactorOther }, "Внешние факторы - Прочее", STANDARD_TEXT_LIMIT),
        Triple({ capitalOutflow.comment }, "Посредники", STANDARD_TEXT_LIMIT),
        Triple(
            { conclusion.summary },
            "Заключение по результатам проведения ФМ (краткий вывод)",
            LONG_TEXT_LIMIT
        ),
        Triple(
            { conclusion.summaryKp },
            "Заключение по результатам проведения ФМ (для информирования КП)",
            MEDIUM_TEXT_LIMIT
        ),
        Triple({ conclusion.expertActions }, "Работы, проведенные сотрудником ГФМ", MEDIUM_TEXT_LIMIT)
    )

    val errors = fieldChecks.mapNotNull { (getter, fieldName, limit) ->
        getter()?.takeIf { it.length > limit }?.let { "\"$fieldName\"" }
    }

    if (errors.isNotEmpty()) {
        throw FrontException(INCORRECT_LENGTH, errors.joinToString(", "))
    }
}

private fun List<String>.throwIfEmpty(validationFailedError: FocusErrorCode) {
    if (isNotEmpty()) throw FrontException(validationFailedError, joinToString("; "))
} как работает эта проверка package ru.sber.poirot.focus.shared.contract

import com.fasterxml.jackson.annotation.JsonIgnore
import ru.sber.poirot.focus.shared.contract.frauds.*
import ru.sber.poirot.focus.shared.contract.parts.BooleanInt
import ru.sber.poirot.focus.shared.contract.parts.Conclusion
import ru.sber.poirot.focus.shared.contract.parts.FraudSigns
import ru.sber.poirot.focus.shared.contract.parts.PB
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto
import java.time.LocalDate

abstract class ChangeRequest {
    abstract val recordId: Long

    // Поля из PB
    protected abstract val beginDate: LocalDate?
    protected abstract val defaultType: String?
    protected abstract val dateLastContract: LocalDate?
    protected abstract val dateCurrentDelay: LocalDate?
    protected abstract val dateNpl90: LocalDate?
    protected abstract val externalFactor: Int?
    protected abstract val externalFactorOther: String?

    // Поля из FraudSigns
    protected abstract val confirmedFraud: Int?
    protected abstract val inProcessFraud: Int?
    protected abstract val incidentOr: Int?
    protected abstract val incidentOrDate: LocalDate?
    protected abstract val internalFraud: Int?
    protected abstract val dateFraud: LocalDate?
    protected abstract val datePotentialFraud: LocalDate?
    protected abstract val dateActualFraud: LocalDate?
    protected abstract val repeatedMonitoring: Int?

    // Поля из CapitalOutflow
    protected abstract val capitalOutflowStartDate: LocalDate?
    protected abstract val capitalOutflowAffectedByDefault: Boolean?
    protected abstract val capitalOutflowComment: String?

    // Поля из FakeReport
    protected abstract val fakeReportType: Int?
    protected abstract val fakeReportAffectedByDefault: Boolean?
    protected abstract val fakeReportAffectedDates: List<LocalDate>

    // Поля из FakeReportDoc
    protected abstract val fakeReportAffectedByDocDefault: Boolean?
    protected abstract val fakeReportAffectedByDocDate: LocalDate?

    // Поля из Bankruptcy
    protected abstract val bankruptcySign: Int?
    protected abstract val bankruptcyAffectedByDefault: Boolean?
    protected abstract val bankruptcyAffectedDate: LocalDate?

    // Поля из Conclusion
    protected abstract val summary: String?
    protected abstract val summaryKp: String?
    protected abstract val expertActions: String?
    abstract val suspicions: SuspicionsDto
    abstract val fraudSchemas: List<Int>?

    // Поля ГФМ
    abstract val monitoringProcessFraudSchemas: List<MonitoringProcessFraudSchema>?

    @get:JsonIgnore
    val pb: PB by lazy {
        PB(beginDate, defaultType, dateLastContract, dateCurrentDelay, dateNpl90, externalFactor, externalFactorOther)
    }

    @get:JsonIgnore
    val fraudSigns: FraudSigns by lazy {
        FraudSigns(
            confirmedFraud?.let { BooleanInt(it) },
            inProcessFraud,
            incidentOr?.let { BooleanInt(it) },
            incidentOrDate,
            internalFraud?.let { BooleanInt(it) },
            dateFraud,
            datePotentialFraud,
            dateActualFraud,
            repeatedMonitoring?.let { BooleanInt(it) },
        )
    }

    @get:JsonIgnore
    val capitalOutflow: CapitalOutflow by lazy {
        CapitalOutflow(
            capitalOutflowStartDate,
            capitalOutflowAffectedByDefault,
            capitalOutflowComment?.ifBlank { null },
        )
    }

    @get:JsonIgnore
    val fakeReport: FakeReport by lazy {
        FakeReport(fakeReportType, fakeReportAffectedByDefault, fakeReportAffectedDates)
    }

    @get:JsonIgnore
    val fakeReportDoc: FakeReportDoc by lazy {
        FakeReportDoc(fakeReportAffectedByDocDefault, fakeReportAffectedByDocDate)
    }

    @get:JsonIgnore
    val bankruptcy: Bankruptcy by lazy {
        Bankruptcy(bankruptcySign, bankruptcyAffectedByDefault, bankruptcyAffectedDate)
    }

    @get:JsonIgnore
    val conclusion: Conclusion by lazy { Conclusion(summary, summaryKp, expertActions) }

    @get:JsonIgnore
    val monitoringProcessFraudSchemasSafe: List<MonitoringProcessFraudSchema> by lazy {
        monitoringProcessFraudSchemas ?: emptyList()
    }
}Сохраняю задачу api/inwork/save с 1 фродом. 

Фактический результат: в focus_monitoring создаются записи фродов и в monitoring_process_fraud_scheme, и таблицах, куда записывается фрод ФМ Ожидаемый результат: фрод записывается только в monitoring_process_fraud_scheme
А ещё возможно из-за этого при отправке на согласование, когда фрод-признаки подтверждены, возникает ошибка, что фрод не добавлен. Он случайно не проверяет наличие фрода в таблицах, куда фрод добавляется в фм?
