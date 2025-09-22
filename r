package ru.sber.poirot.focus.shared.dictionaries

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import ru.sber.poirot.audit.AuditClient

@RestController
@RequestMapping("/api")
class DictionariesController(
    private val auditClient: AuditClient,
    private val dictionaries: Dictionaries
) {

    @GetMapping("/dicts")
    suspend fun getDicts(): DictionaryDto = auditClient.audit(event = "FM_DICTS_RECEIVED") {
        dictionaries.getDicts()
    }
}package ru.sber.poirot.focus.shared.dictionaries

import ru.sber.poirot.focus.shared.dictionaries.DictionaryType.*

// todo refactor replace with caches
interface Dictionaries {
    fun bankruptcySign(): Map<Int?, String>

    fun externalFactor(): Map<Int?, String>

    fun fakeReportType(): Map<Int?, String>

    fun fraudScheme(): Map<Int?, String>

    suspend fun suspicionFraudSchemes(): Map<Int?, String>

    fun inputSource(): Map<Int?, String>

    fun defaultProcessType(): Map<Int?, String>

    fun monitoringStatus(): Map<Int?, String>

    fun inProcessFraud(): Map<Int?, String>

    fun slaByDefault(): Map<Int?, String>

    fun segments(): List<String>

    fun getValueById(id: Int?, dictType: DictionaryType): String?

    fun getIdByValue(value: String, dictType: DictionaryType): Int

    fun getDictByType(dictType: DictionaryType): Map<Int?, String> =
        when (dictType) {
            BANKRUPTCY_SIGN -> bankruptcySign()
            EXTERNAL_FACTOR -> externalFactor()
            FAKE_REPORT_TYPE -> fakeReportType()
            INPUT_SOURCE -> inputSource()
            FRAUD_SCHEME -> fraudScheme()
            DEFAULT_PROCESS_TYPE -> defaultProcessType()
            MONITORING_STATUS -> monitoringStatus()
            IN_PROCESS_FRAUD -> inProcessFraud()
            SLA_BY_DEFAULT -> slaByDefault()
        }

    suspend fun getDicts(): DictionaryDto =
        DictionaryDto(
            bankruptcySign = bankruptcySign(),
            externalFactor = externalFactor(),
            fakeReportType = fakeReportType(),
            inputSource = inputSource(),
            defaultProcessType = defaultProcessType(),
            monitoringStatus = monitoringStatus(),
            inProcessFraud = inProcessFraud(),
            fraudScheme = fraudScheme(),
            segments = segments(),
            suspicionFraudSchemes = suspicionFraudSchemes(),
            slaByDefault = slaByDefault()
        )
}package ru.sber.poirot.focus.shared.dictionaries

import org.springframework.stereotype.Service
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.model.*
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.DICT_ID_NOT_FOUND
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.DICT_VALUE_NOT_FOUND
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps

@Service
class DictionariesImpl : Dictionaries {

    override fun bankruptcySign(): Map<Int?, String> = BankruptcySign.bankruptcySigns

    override fun externalFactor(): Map<Int?, String> = ExternalFactor.externalFactors

    override fun fakeReportType(): Map<Int?, String> = FakeReportType.fakeReportTypes

    override fun fraudScheme(): Map<Int?, String> = FraudScheme.fraudSchemeValueById

    override suspend fun suspicionFraudSchemes(): Map<Int?, String> =
        fraudSchemeCorps.asSet().associate { it.id to it.name }

    override fun inputSource(): Map<Int?, String> = InputSource.getIdToSource()

    override fun defaultProcessType(): Map<Int?, String> = defaultProcessTypesCache.asMap()

    override fun monitoringStatus(): Map<Int?, String> = MonitoringStatus.getIdToStatus()

    override fun inProcessFraud(): Map<Int?, String> = inProcessFraudsCache.asMap()

    override fun slaByDefault(): Map<Int?, String> = slaByDefaultCashe.asMap()

    override fun segments(): List<String> = corpcustSegments.asSet().toList()

    override fun getValueById(id: Int?, dictType: DictionaryType): String? {
        if (id == null || id == 0) return null
        return getDictByType(dictType)[id.toInt()]
            ?: throw FrontException(DICT_VALUE_NOT_FOUND, ": $dictType для id: $id")
    }

    override fun getIdByValue(value: String, dictType: DictionaryType): Int =
        getDictByType(dictType).entries.find { it.value == value }?.key
            ?: throw FrontException(DICT_ID_NOT_FOUND, ": $dictType value: $value")
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
const val gfmFraudSource: String = "monitoring_ksb"
const val gfmTypeFraud: String = "Последующий"


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
}package ru.sber.poirot.focus.stages

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.inProcessFraudsCache
import ru.sber.poirot.focus.shared.dictionaries.model.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudCode.SUSPICION
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.Companion.fraudSchemes
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.fraud.client.KtorFraudClient
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.fraud.model.FraudRegistryType
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
        val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
        return if (processType == 11 && !monitoringProcessFraudSchemas.isNullOrEmpty()) {
            val monitoringFrauds = monitoringProcessFraudSchemas.map { scheme ->
                FraudRecord.fraudRecord(
                    type = FraudRegistryType.LE_CLIENT.type,
                    key = inn!!,
                    keyNoApp = inn,
                    fraudStatus = SUSPICION.code,
                    scheme = fraudReasonsCorp.first { it.id == scheme.fraudSchemeId }.key,
                    source = "monitoring_ksb",
                    fullComment = scheme.fullComment ?: summary,
                    shortComment = scheme.shortComment ?: summaryKp,
                    login = executor,
                    dateTime = LocalDateTime.now(),
                    typeFraud = "Последующий",
                    incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                    corpControlMode = fmFraudCorpControlMode,
                    fraudAdditionalInfo = null
                )
            }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                gfmFraudSource,
                executor ?: throw FrontException("Исполнитель должен быть назначен"),
                gfmTypeFraud
            )

            (monitoringFrauds + fraudsBySuspicions).distinct()
        } else {
            val generalFrauds = fraudSchemes.mapNotNull { it.fraudRecord(this, canBeDeleted, inProcessFraud) }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                fmFraudSource,
                fmFraudLogin,
                typeFraud(inProcessFraud)
            )
            (generalFrauds + fraudsBySuspicions).distinct()
        }
    }

    private fun FmRecord.fraudRecordsBySuspicions(
        fraudSchemes: List<FraudReasonsCorp>,
        source: String?,
        login: String,
        typeFraud: String?
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
                source = source,
                fullComment = summary,
                shortComment = summaryKp,
                login = login,
                dateTime = LocalDateTime.now(),
                typeFraud = typeFraud,
                incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                corpControlMode = fmFraudCorpControlMode,
                fraudAdditionalInfo = null,
            )
        }
} у менять есть справочник fraudReasonCorp в нем намного больше фрод признаков чем описано в енаме и id у нхи не совпаадают.  (Леша, привет. Короче хотел обсудить момент со вкладкой влияние на дефолт
15:02
где списо фрод признаков
15:02
тебе же сейчас приходит 4 id и ты их соотвественно отправляешь
15:02
наверное, речь выпадашку "схемы фрода". ну да, я беру словарь и делаю из него выпадашку с галочками для выбора
15:12
Алексей Птицын
наверное, речь выпадашку "схемы фрода". ну да, я беру словарь и делаю из него выпадашку с галочками для выбора
да, ща у тебя там всего 4 признака приходит) как лучше сделать чтоб использовать один справочник и  id из не го а не этот енам подскажи 
