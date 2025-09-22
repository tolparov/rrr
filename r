
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
} package ru.sber.poirot.focus.shared.records.model

import ru.sber.poirot.engine.model.api.monitoring.FocusMonitoringRecord
import ru.sber.poirot.focus.shared.contract.frauds.*
import ru.sber.poirot.focus.shared.contract.frauds.Bankruptcy.Companion.toBankruptcyModel
import ru.sber.poirot.focus.shared.contract.frauds.CapitalOutflow.Companion.toCapitalOutflowModel
import ru.sber.poirot.focus.shared.contract.frauds.FakeReport.Companion.toFakeReportModel
import ru.sber.poirot.focus.shared.contract.frauds.FakeReportDoc.Companion.toFakeReportDocModel
import ru.sber.poirot.focus.shared.contract.frauds.MonitoringProcessFraudSchema.Companion.toMonitoringProcessFraudSchemeModel
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto.Companion.EmptySuspicionsDto
import ru.sber.poirot.process.shared.Task
import java.time.LocalDate
import java.time.LocalDateTime
import ru.sber.poirot.engine.model.full.monitoring.FakeReport as FullFakeReport
import ru.sber.poirot.engine.model.full.monitoring.FakeReportDate as FullFakeReportDate
import ru.sber.poirot.engine.model.full.monitoring.FocusMonitoringRecord as FullFocusMonitoringRecord

data class FmRecord(
    val taskId: Long = 0,
    val aspId: Long? = null,
    val eventId: Long? = null,
    val inputSource: Int,
    val processType: Int,
    val dateCreate: LocalDateTime? = null,
    val dateInitiation: LocalDateTime? = null,
    val dateApproval: LocalDateTime? = null,
    val dateDelete: LocalDateTime? = null,
    val statusId: Int,
    val initiator: String? = null,
    override val executor: String? = null,
    val inn: String? = null,
    val name: String? = null,
    val clientId: String? = null,
    val epkId: String? = null,
    val opf: String? = null,
    val defaultType: String? = null,
    val beginDate: LocalDate? = null,
    val segment: String? = null,
    val macroIndustry: String? = null,
    val gre: String? = null,
    val consGroupName: String? = null,
    val approver: String? = null,
    val confirmedFraud: Boolean? = null,
    val inProcessFraud: Int? = null,
    val dateFraud: LocalDate? = null,
    val fraudSchemas: String? = null,
    val riskSegment: String? = null,
    val repeatedMonitoring: Boolean? = null,
    val incidentOr: Boolean? = null,
    val summary: String? = null,
    val summaryKp: String? = null,
    val expertActions: String? = null,
    val dateLastContract: LocalDate? = null,
    val dateCurrentDelay: LocalDate? = null,
    val externalFactor: Int? = null,
    val externalFactorOther: String? = null,
    val clientDivision: String? = null,
    val internalFraud: Boolean? = null,
    val dateNpl90: LocalDate? = null,
    val reasonReturn: String? = null,
    val datePotentialFraud: LocalDate? = null,
    val dateActualFraud: LocalDate? = null,
    val incidentOrDate: LocalDate? = null,
    val slaByDefault: Int? = null,
    val initiatorComment: String? = null,
    val capitalOutFlow: CapitalOutflow? = null,
    val fakeReport: FakeReport? = null,
    val fakeReportDoc: FakeReportDoc? = null,
    val bankruptcy: Bankruptcy? = null,
    val suspicions: SuspicionsDto,
    val monitoringProcessFraudSchemas: List<MonitoringProcessFraudSchema>? = emptyList()
) : Task<MonitoringStatus> {
    override val id: String get() = taskId.toString()
    override val status: MonitoringStatus = MonitoringStatus.getStatusById(statusId)
        ?: throw IllegalStateException("Incorrect fm status")

    fun toFocusMonitoringRecord(): FocusMonitoringRecord =
        FullFocusMonitoringRecord().apply {
            val self = this@FmRecord

            id = self.taskId
            aspId = self.aspId
            eventId = self.eventId
            inputSource = self.inputSource
            processType = self.processType
            dateCreate = self.dateCreate
            dateInitiation = self.dateInitiation
            dateApproval = self.dateApproval
            dateDelete = self.dateDelete
            status = self.statusId
            initiator = self.initiator
            executor = self.executor
            inn = self.inn
            name = self.name
            clientId = self.clientId
            epkId = self.epkId
            opf = self.opf
            defaultType = self.defaultType
            beginDate = self.beginDate
            segment = self.segment
            macroIndustry = self.macroIndustry
            gre = self.gre
            consGroupName = self.consGroupName
            approver = self.approver
            confirmedFraud = self.confirmedFraud
            inProcessFraud = self.inProcessFraud
            dateFraud = self.dateFraud
            fraudSchemas = self.fraudSchemas
            riskSegment = self.riskSegment
            repeatedMonitoring = self.repeatedMonitoring
            incidentOr = self.incidentOr
            summary = self.summary
            summaryKp = self.summaryKp
            expertActions = self.expertActions
            dateLastContract = self.dateLastContract
            dateCurrentDelay = self.dateCurrentDelay
            externalFactor = self.externalFactor
            externalFactorOther = self.externalFactorOther
            clientDivision = self.clientDivision
            internalFraud = self.internalFraud
            dateNpl90 = self.dateNpl90
            datePotentialFraud = self.datePotentialFraud
            dateActualFraud = self.dateActualFraud
            incidentOrDate = self.incidentOrDate
            slaByDefault = self.slaByDefault
            initiatorComment = self.initiatorComment
            reasonReturn = self.reasonReturn
            capitalOutflow = self.capitalOutFlow?.toRecord()
            fakeReport = fakeReportRecordFrom(self.fakeReport, self.fakeReportDoc)
            bankruptcy = self.bankruptcy?.toRecord()
            monitoringProcessFraudSchemes = self.monitoringProcessFraudSchemas?.map { it.toRecord() }
        }

    private fun fakeReportRecordFrom(fakeReport: FakeReport?, fakeReportDoc: FakeReportDoc?): FullFakeReport =
        FullFakeReport().apply {
            fakeReport?.also {
                type = fakeReport.type
                affectedByDefault = fakeReport.affectedByDefault
                affectedDate = fakeReport.affectedDates.minOrNull()
                affectedDates = fakeReport.affectedDates.map {
                    FullFakeReportDate().apply { this@apply.affectedDate = it }
                }
            }
            fakeReportDoc?.also {
                affectedByDocDefault = fakeReportDoc.affectedByDefault
                affectedByDocDate = fakeReportDoc.affectedDate
            }
        }

    companion object {
        fun FocusMonitoringRecord.toFocusRecord(suspicions: SuspicionsDto = EmptySuspicionsDto): FmRecord =
            FmRecord(
                taskId = id,
                aspId = aspId,
                eventId = eventId,
                inputSource = inputSource,
                processType = processType,
                dateCreate = dateCreate,
                dateInitiation = dateInitiation,
                dateApproval = dateApproval,
                dateDelete = dateDelete,
                statusId = status,
                initiator = initiator,
                executor = executor,
                inn = inn,
                name = name,
                epkId = epkId,
                opf = opf,
                defaultType = defaultType,
                beginDate = beginDate,
                segment = segment,
                macroIndustry = macroIndustry,
                gre = gre,
                consGroupName = consGroupName,
                approver = approver,
                confirmedFraud = confirmedFraud,
                inProcessFraud = inProcessFraud,
                dateFraud = dateFraud,
                fraudSchemas = fraudSchemas,
                riskSegment = riskSegment,
                repeatedMonitoring = repeatedMonitoring,
                incidentOr = incidentOr,
                summary = summary,
                summaryKp = summaryKp,
                expertActions = expertActions,
                dateLastContract = dateLastContract,
                dateCurrentDelay = dateCurrentDelay,
                externalFactor = externalFactor,
                externalFactorOther = externalFactorOther,
                clientDivision = clientDivision,
                internalFraud = internalFraud,
                dateNpl90 = dateNpl90,
                reasonReturn = reasonReturn,
                datePotentialFraud = datePotentialFraud,
                dateActualFraud = dateActualFraud,
                incidentOrDate = incidentOrDate,
                slaByDefault = slaByDefault,
                initiatorComment = initiatorComment,
                capitalOutFlow = capitalOutflow?.toCapitalOutflowModel(),
                fakeReport = fakeReport?.toFakeReportModel(),
                fakeReportDoc = fakeReport?.toFakeReportDocModel(),
                bankruptcy = bankruptcy?.toBankruptcyModel(),
                suspicions = suspicions,
                monitoringProcessFraudSchemas = monitoringProcessFraudSchemes?.map { it.toMonitoringProcessFraudSchemeModel() }
            )
    }
}package ru.sber.poirot.focus.shared.contract.frauds

import ru.sber.poirot.engine.model.api.monitoring.MonitoringProcessFraudScheme
import ru.sber.poirot.engine.model.full.monitoring.MonitoringProcessFraudScheme as FullMonitoringProcessFraudScheme


data class MonitoringProcessFraudSchema(
    val fraudSchemeId: Int,
    val shortComment: String?,
    val fullComment: String?
) {
    fun toRecord(): FullMonitoringProcessFraudScheme=
        FullMonitoringProcessFraudScheme().apply {
            val self = this@MonitoringProcessFraudSchema

            fraudSchemeId = self.fraudSchemeId
            shortComment = self.shortComment
            fullComment = self.fullComment
        }

    companion object {
        fun MonitoringProcessFraudScheme.toMonitoringProcessFraudSchemeModel(): MonitoringProcessFraudSchema =
            MonitoringProcessFraudSchema(
                fraudSchemeId = fraudSchemeId,
                shortComment = shortComment,
                fullComment = fullComment,
            )
    }
}

