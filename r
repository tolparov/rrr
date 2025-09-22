
package ru.sber.poirot.focus.stages

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp
import ru.sber.poirot.focus.shared.dictionaries.inProcessFraudsCache
import ru.sber.poirot.focus.shared.dictionaries.model.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudCode.SUSPICION
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.Companion.fraudSchemes
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.fraud.client.KtorFraudClient
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps
import ru.sber.utils.ifNotEmpty
import ru.sber.utils.logger
import java.time.LocalDate
import java.time.LocalDateTime

@Service
class FmFraudManager(private val ktorFraudClient: KtorFraudClient) : FraudManager<FmRecord> {
    private val log = logger()

    override suspend fun addFrauds(records: List<FmRecord>) {
        val inProcessFraudsByCode = inProcessFraudsCache.asMap()
        records.filter { it.confirmedFraud == true }
            .flatMap {
                it.fraudRecords(
                    fraudSchemes = fraudSchemes,
                    canBeDeleted = false,
                    inProcessFraud = inProcessFraudsByCode[it.inProcessFraud],
                )
            }
            .also { log.info("Adding ${it.size} fraud records:\n$it") }
            .ifNotEmpty { ktorFraudClient.addFrauds(it) }
    }

    override suspend fun editFrauds(recordPairs: List<FraudManager.RecordPair<FmRecord>>) {
        val inProcessFraudsByCode = inProcessFraudsCache.asMap()
        recordPairs
            .flatMap {
                it.new.fraudRecords(
                    fraudSchemes = it.getUpdatedFraudSchemes(),
                    canBeDeleted = true,
                    inProcessFraud = inProcessFraudsByCode[it.new.inProcessFraud]
                )
            }
            .also { log.info("Editing ${it.size} fraud records:\n$it") }
            .ifNotEmpty { ktorFraudClient.addFrauds(it) }
    }

    private fun FraudManager.RecordPair<FmRecord>.getUpdatedFraudSchemes(): List<FraudScheme> = buildList {
        if (new.capitalOutFlow != previous.capitalOutFlow) add(CAPITAL_OUTFLOW)
        if (new.bankruptcy != previous.bankruptcy) add(BANKRUPTCY)
        if (new.fakeReportDoc != previous.fakeReportDoc) add(FAKE_DOC)
        if (new.fakeReport != previous.fakeReport) add(FAKE_REPORT)
        if (new.inProcessFraud != previous.inProcessFraud
            || new.summary != previous.summary
            || new.summaryKp != previous.summaryKp
            || new.dateFraud != previous.dateFraud
        ) {
            if (new.capitalOutFlow?.isNotEmpty == true) add(CAPITAL_OUTFLOW)
            if (new.bankruptcy?.isNotEmpty == true) add(BANKRUPTCY)
            if (new.fakeReportDoc?.isNotEmpty == true) add(FAKE_DOC)
            if (new.fakeReport?.isNotEmpty == true) add(FAKE_REPORT)
        }
    }.distinct()

    private fun FmRecord.fraudRecords(
        fraudSchemes: List<FraudScheme>,
        canBeDeleted: Boolean,
        inProcessFraud: String?,
    ): List<FraudRecord> {
        return if (processType == 11) {
            monitoringProcessFraudSchemes.map { scheme ->
                FraudRecord.fraudRecord(
                    type = scheme.type, // "ЮЛ:КлиентОрганизация" или "ЮЛ:ФИОДР" и т.д.
                    key = scheme.key,
                    keyNoApp = scheme.key,
                    fraudStatus = SUSPICION.code, // всегда suspicion для monitoring_process = true
                    scheme = scheme.scheme, // monitoring_process_fraud_scheme.scheme
                    source = "monitoring_ksb",
                    fullComment = scheme.fullComment,
                    shortComment = scheme.shortComment,
                    login = executor,
                    dateTime = LocalDateTime.now(),
                    typeFraud = "Последующий",
                    incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                    corpControlMode = fmFraudCorpControlMode,
                    fraudAdditionalInfo = null,
                )
            }
        } else {
            val generalFrauds = fraudSchemes.mapNotNull { it.fraudRecord(this, canBeDeleted, inProcessFraud) }
            val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
            val fraudsBySuspicions = fraudRecordsBySuspicions(inProcessFraud, fraudReasonsCorp)
            (generalFrauds + fraudsBySuspicions).distinct()
        }
    }

    private fun FmRecord.fraudRecordsBySuspicions(
        inProcessFraud: String?,
        fraudSchemes: List<FraudReasonsCorp>,
    ): List<FraudRecord> = suspicions.suspicions(fraudSchemes)
        .suspicionEntities()
        .map { suspicionEntity ->
            val fraudKey = suspicionEntity.fraudKey()
            FraudRecord.fraudRecord(
                type = fraudKey.type,
                key = fraudKey.key,
                keyNoApp = fraudKey.key,
                fraudStatus = SUSPICION.code,
                scheme = fraudKey.scheme,
                source = fmFraudSource,
                fullComment = summary,
                shortComment = summaryKp,
                login = fmFraudLogin,
                dateTime = LocalDateTime.now(),
                typeFraud = typeFraud(inProcessFraud),
                incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                corpControlMode = fmFraudCorpControlMode,
                fraudAdditionalInfo = null,
            )
        }
}package ru.sber.poirot.focus.shared.dictionaries.model

import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.fraud.model.FraudRecord.Companion.fraudRecord
import ru.sber.poirot.fraud.model.FraudRegistryType.LE_CLIENT
import java.time.LocalDate
import java.time.LocalDateTime

enum class FraudScheme(val id: Int, val code: String, val scheme: String) {

    CAPITAL_OUTFLOW(1, "capital_outflow", "Вывод капитала") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf {
                canBeDeleted || with(it.capitalOutFlow) { this != null && startDate != null && comment != null }
            }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.capitalOutFlow?.startDate == null,
                    affectedByDefault = record.capitalOutFlow?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = listOfNotNull(record.capitalOutFlow?.startDate),
                fraudInfluenceOnDefault = record.capitalOutFlow?.affectedByDefault ?: false,
            )
    },
    BANKRUPTCY(2, "bankruptcy", "Преднамеренное/фиктивное банкротство") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf {
                canBeDeleted || with(it.bankruptcy) { this != null && affectedDate != null && sign != null }
            }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.bankruptcy?.affectedDate == null,
                    affectedByDefault = record.bankruptcy?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = listOfNotNull(record.bankruptcy?.affectedDate),
                fraudInfluenceOnDefault = record.bankruptcy?.affectedByDefault ?: false,
            )
    },
    FAKE_DOC(3, "fake_doc", "Фальсификация документов") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf { canBeDeleted || with(it.fakeReportDoc) { this != null && affectedDate != null } }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.fakeReportDoc?.affectedDate == null,
                    affectedByDefault = record.fakeReportDoc?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = listOfNotNull(record.fakeReportDoc?.affectedDate),
                fraudInfluenceOnDefault = record.fakeReportDoc?.affectedByDefault ?: false,
            )
    },
    FAKE_REPORT(4, "fake_report", "Фальсификация отчетности") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf {
                canBeDeleted || with(it.fakeReport) { this != null && affectedDates.isNotEmpty() && affectedByDefault != null }
            }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.fakeReport?.affectedDates.isNullOrEmpty(),
                    affectedByDefault = record.fakeReport?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = record.fakeReport?.affectedDates ?: emptyList(),
                fraudInfluenceOnDefault = record.fakeReport?.affectedByDefault ?: false,
            )
    };

    abstract fun fraudRecord(record: FmRecord, canBeDeleted: Boolean, inProcessFraud: String?): FraudRecord?

    companion object {
        val fraudSchemes = entries.toList()
        private val fraudSchemeById: Map<Int?, FraudScheme> = fraudSchemes.associateBy { it.id }

        val fraudSchemeValueById: Map<Int?, String> = fraudSchemeById.mapValues { it.value.scheme }
        val fraudSchemeIdByCode: Map<String, Int> = fraudSchemes.associate { it.code to it.id }

        fun fraudSchemeCodeById(id: Int): String =
            fraudSchemeById[id]?.code ?: throw IllegalStateException("Incorrect fraud scheme id: $id")
    }
}

const val fmFraudCorpControlMode: String = "off-line"
const val fmFraudSource: String = "focus_monitoring"
const val fmFraudLogin: String = "autocomplete_focus_monitoring"

fun typeFraud(inProcessFraud: String?): String = when (inProcessFraud) {
    "Предкредитка" -> "Преднамеренный"
    else -> "Последующий"
}

private fun FmRecord.makeFraudRecord(
    inProcessFraud: String?,
    scheme: String,
    fraudStatus: String?,
    fraudAdditionalDates: List<LocalDate> = emptyList(),
    fraudInfluenceOnDefault: Boolean,
): FraudRecord? = when {
    fraudStatus == null -> null
    else -> fraudRecord(
        type = LE_CLIENT.type,
        key = inn!!,
        keyNoApp = inn,
        fraudStatus = fraudStatus,
        scheme = scheme,
        source = fmFraudSource,
        fullComment = summary,
        shortComment = summaryKp,
        login = fmFraudLogin,
        typeFraud = typeFraud(inProcessFraud),
        dateTime = LocalDateTime.now(),
        incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
        corpControlMode = fmFraudCorpControlMode,
        fraudAdditionalInfo = dateFraud?.let {
            FraudRecord.FraudAdditionalInfo(
                fraudStartDate = dateFraud,
                fraudInfluenceOnDefault = fraudInfluenceOnDefault,
                fraudAdditionalDates = fraudAdditionalDates,
            )
        },
    )
} давай еще раз 
