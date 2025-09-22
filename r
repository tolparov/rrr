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
}задача с monitoringProcessFraudSchemas в статусе "Согласование". После отправки на доработку, эндпоинт api/agreement/return-to-work/616001, создаются дубли добавленного фрода в monitoring_process_fraud_schemepackage ru.sber.poirot.focus.stages.agreement

import io.swagger.v3.oas.annotations.Parameter
import org.springframework.web.bind.annotation.*
import ru.sber.poirot.CurrentUser
import ru.sber.poirot.audit.AuditClient

@RequestMapping("/api/agreement")
@RestController
class AgreementController(
    private val auditClient: AuditClient,
    private val currentUser: CurrentUser,
    private val agreementService: AgreementService,
) {

    @PostMapping("/agree/{recordId}")
    suspend fun agree(
        @PathVariable
        @Parameter(name = "recordId", description = "ID задачи Фокусного Мониторинга")
        recordId: Long,
    ) =
        auditClient.audit(event = "FOCUS_AGREED", details = "recordId: $recordId") {
            agreementService.agree(recordId, currentUser.userName())
        }

    @PostMapping("/return-to-work/{recordId}")
    suspend fun returnToWork(
        @PathVariable
        @Parameter(name = "recordId", description = "ID задачи Фокусного Мониторинга")
        recordId: Long,
        @RequestBody request: AgreementRequest,
    ) =
        auditClient.audit(event = "FOCUS_RETURNED_TO_WORK_SEND", details = "recordId: $recordId, request: $request") {
            agreementService.returnToWork(recordId, request)
        }
}package ru.sber.poirot.focus.stages.agreement

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.request.ParallelRunProcessDisRequestManager
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.*
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.INCORRECT_STATUS
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto.Companion.EmptySuspicionsDto
import ru.sber.poirot.focus.shared.records.suspicion.suspicionsDto
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps
import ru.sber.poirot.suspicion.manage.SuspicionManager
import ru.sber.poirot.utils.transactionalWithReactorContext
import java.time.LocalDateTime
import java.time.LocalDateTime.now

@Service
class AgreementServiceImpl(
    private val focusDao: FmRecordDao,
    private val parallelRunProcessDisRequestManager: ParallelRunProcessDisRequestManager<FmRecord>,
    private val fraudManager: FraudManager<FmRecord>,
    private val suspicionManager: SuspicionManager,
) : AgreementService {

    override suspend fun agree(recordId: Long, login: String) {
        val focusRecord = focusRecord(recordId, AGREED, login, now()) {
            suspicionManager
                .fetch(recordId.toString())
                .suspicionsDto(fraudSchemeCorps.asSet().toList())
        }

        transactionalWithReactorContext {
            focusDao.merge(focusRecord.toFocusMonitoringRecord())
            parallelRunProcessDisRequestManager.notifyDone(focusRecord, focusRecord.confirmedFraud?.let { !it })
            fraudManager.addFrauds(focusRecord)
        }
    }

    override suspend fun returnToWork(recordId: Long, request: AgreementRequest): Unit =
        focusDao.merge(
            focusRecord(
                recordId,
                IN_WORK,
                reasonReturn = request.reasonReturn
            ).toFocusMonitoringRecord()
        )

    private suspend fun focusRecord(
        recordId: Long,
        status: MonitoringStatus,
        login: String? = null,
        dateApproval: LocalDateTime? = null,
        reasonReturn: String? = null,
        suspicionsFetcher: suspend () -> SuspicionsDto = { EmptySuspicionsDto },
    ): FmRecord = focusDao.findRecordBy(recordId, listOf(AGREEMENT.id))
        ?.copy(
            statusId = status.id,
            approver = login,
            dateApproval = dateApproval,
            reasonReturn = reasonReturn,
            suspicions = suspicionsFetcher()
        ) ?: throw FrontException(INCORRECT_STATUS, "$AGREEMENT")
}package ru.sber.poirot.focus.shared.records.model

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
} кpackage ru.sber.poirot.focus.shared.contract.frauds

import ru.sber.poirot.engine.model.api.monitoring.MonitoringProcessFraudScheme
import ru.sber.poirot.engine.model.full.monitoring.MonitoringProcessFraudScheme as FullMonitoringProcessFraudScheme

data class MonitoringProcessFraudSchema(
    val fraudSchemeId: Int,
    val shortComment: String?,
    val fullComment: String?,
) : Checked {
    override val blockName: String = "Фрод-схемы мониторинга"

    override val affectedByDefault: Boolean? = null

    override val isEmpty: Boolean =
        fraudSchemeId == 0 && shortComment.isNullOrBlank() && fullComment.isNullOrBlank()

    override val confirmedChecks: Map<Boolean, String> = mapOf(
        (fraudSchemeId == 0) to "Схема фрода"
    )

    override val notConfirmedChecks: Map<Boolean, String> = mapOf(
        (fraudSchemeId != 0) to "Схема фрода"
    )

    fun toRecord(): FullMonitoringProcessFraudScheme =
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
 как сделать чтоб дубликаты не появлялись
