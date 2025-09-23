package ru.sber.poirot.focus.shared.records.model

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
}package ru.sber.poirot.focus.viewer.strategy

import ru.sber.poirot.dpa.reassignment.impl.info.ReassignmentInfo
import ru.sber.poirot.dpa.sla.SlaInfo
import ru.sber.poirot.focus.shared.dictionaries.model.SlaByDefault.Companion.getHoursById
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto
import ru.sber.poirot.focus.shared.toIntFraudSchemas
import ru.sber.poirot.focus.viewer.ViewRecord
import ru.sber.poirot.focus.viewer.ViewResponse

fun FmRecord.toViewResponse(
    suspicions: SuspicionsDto,
    reassignmentInfo: ReassignmentInfo?,
    slaInfo: SlaInfo?,
): ViewResponse =
    ViewResponse(
        record = toViewRecord(suspicions),
        stage = statusId,
        reassignmentInfo = reassignmentInfo,
        slaInfo = slaInfo,
    )

fun FmRecord.toViewRecord(suspicions: SuspicionsDto): ViewRecord =
    ViewRecord(
        recordId = taskId,
        inputSource = inputSource,
        processType = processType,
        dateCreate = dateCreate,
        dateInitiation = dateInitiation,
        clientId = clientId,
        epkId = epkId,
        name = name,
        inn = inn,
        segment = segment,
        riskSegment = riskSegment,
        macroIndustry = macroIndustry,
        gre = gre,
        consGroupName = consGroupName,
        clientDivision = clientDivision,
        beginDate = beginDate,
        defaultType = defaultType,
        dateCurrentDelay = dateCurrentDelay,
        dateLastContract = dateLastContract,
        externalFactor = externalFactor,
        externalFactorOther = externalFactorOther,
        dateNpl90 = dateNpl90,
        confirmedFraud = confirmedFraud.toViewIntCode(),
        inProcessFraud = inProcessFraud,
        dateFraud = dateFraud,
        incidentOr = incidentOr.toViewIntCode(),
        fraudSchemas = fraudSchemas.toIntFraudSchemas(),
        repeatedMonitoring = repeatedMonitoring.toViewIntCode(),
        internalFraud = internalFraud.toViewIntCode(),
        summary = summary,
        summaryKp = summaryKp,
        expertActions = expertActions,
        reasonReturn = reasonReturn,
        datePotentialFraud = datePotentialFraud,
        dateActualFraud = dateActualFraud,
        incidentOrDate = incidentOrDate,
        slaByDefault = slaByDefault?.let { getHoursById(it) },
        initiatorComment = initiatorComment,

        capitalOutflowStartDate = capitalOutFlow?.startDate,
        capitalOutflowAffectedByDefault = capitalOutFlow?.affectedByDefault,
        capitalOutflowComment = capitalOutFlow?.comment,

        fakeReportType = fakeReport?.type,
        fakeReportAffectedByDefault = fakeReport?.affectedByDefault,
        fakeReportAffectedByDocDefault = fakeReportDoc?.affectedByDefault,
        fakeReportAffectedDate = fakeReport?.affectedDates?.minOrNull(),
        fakeReportAffectedDates = fakeReport?.affectedDates ?: emptyList(),
        fakeReportAffectedByDocDate = fakeReportDoc?.affectedDate,

        bankruptcySign = bankruptcy?.sign,
        bankruptcyAffectedByDefault = bankruptcy?.affectedByDefault,
        bankruptcyAffectedDate = bankruptcy?.affectedDate,

        suspicions = suspicions,
        monitoringProcessFraudSchemas = monitoringProcessFraudSchemas

    )

private fun Boolean?.toViewIntCode(): Int = when {
    this == null -> 0
    this -> 1
    else -> 2
}package ru.sber.poirot.focus.shared.dictionaries.model

enum class SlaByDefault(val id: Int, val hours: String) {
    FIVE_HALF(1, "5.5 ч."),
    EIGHT(2, "8 ч."),
    TWELVE(3, "12 ч.");

    companion object {
        fun asMap(): Map<Int?, String> =
            entries.associate { it.id to it.hours }

        fun getHoursById(id: Int): String =
            entries.find { it.id == id }?.hours
                ?: throw IllegalArgumentException("SLA с id=$id не найдено")

        fun fromHours(hours: String): SlaByDefault =
            entries.find { it.hours.equals(hours.trim(), ignoreCase = true) }
                ?: throw IllegalArgumentException("Некорректное SLA значение: $hours")

        fun getIdByHours(hours: String): Int = entries.find { it.hours.equals(hours.trim(), ignoreCase = true) }?.id
            ?: throw IllegalArgumentException("Некорректное SLA значение: $hours")
    }
}
