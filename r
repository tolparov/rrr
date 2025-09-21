package ru.sber.poirot.focus.shared.contract

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
} package ru.sber.poirot.focus.shared.contract.frauds

data class MonitoringProcessFraudSchema(
    val fraudSchemeId: Int,
    val shortComment: String?,
    val fullComment: String?
)
package ru.sber.poirot.focus.shared.contract

import ru.sber.poirot.engine.model.full.monitoring.*
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.records.model.FmRecord

fun ChangeRequest.toFocusMonitoringRecord(
    record: FmRecord,
    newStatus: MonitoringStatus? = null,
): FocusMonitoringRecord {
    val self = this@toFocusMonitoringRecord

    return FocusMonitoringRecord().apply {
        id = self.recordId
        status = when {
            newStatus != null -> newStatus.id
            else -> record.statusId
        }
        inn = record.inn
        inputSource = record.inputSource
        processType = record.processType
        beginDate = self.pb.beginDate
        dateApproval = record.dateApproval
        dateCurrentDelay = self.pb.dateCurrentDelay
        dateLastContract = self.pb.dateLastContract
        externalFactor = self.pb.externalFactor
        externalFactorOther = self.pb.externalFactorOther
        dateNpl90 = self.pb.dateNpl90
        confirmedFraud = self.fraudSigns.confirmedFraud?.value
        inProcessFraud = self.fraudSigns.inProcessFraud
        dateFraud = self.fraudSigns.dateFraud
        incidentOr = self.fraudSigns.incidentOr?.value
        fraudSchemas = self.fraudSchemas.toStringFraudSchemas()
        repeatedMonitoring = self.fraudSigns.repeatedMonitoring?.value
        internalFraud = self.fraudSigns.internalFraud?.value
        summary = self.conclusion.summary
        summaryKp = self.conclusion.summaryKp
        expertActions = self.conclusion.expertActions
        defaultType = self.pb.defaultType
        datePotentialFraud = self.fraudSigns.datePotentialFraud
        dateActualFraud = self.fraudSigns.dateActualFraud
        incidentOrDate = self.fraudSigns.incidentOrDate
        capitalOutflow = self.capitalOutflow()
        fakeReport = self.fakeReport()
        bankruptcy = self.bankruptcy()
        monitoringProcessFraudSchemes = self.monitoringProcessFraudSchemas.toMonitoringProcessFraudSchema()
    }
}

fun ChangeRequest.capitalOutflow(): CapitalOutflow {
    val self = this@capitalOutflow
    return CapitalOutflow().apply {
        affectedByDefault = self.capitalOutflow.affectedByDefault
        startDate = self.capitalOutflow.startDate
        comment = self.capitalOutflow.comment
    }
}

fun ChangeRequest.fakeReport(): FakeReport {
    val self = this@fakeReport
    return FakeReport().apply {
        affectedDate = self.fakeReport.affectedDates.minOrNull()
        type = self.fakeReport.type
        affectedByDefault = self.fakeReport.affectedByDefault
        affectedByDocDefault = self.fakeReportDoc.affectedByDefault
        affectedByDocDate = self.fakeReportDoc.affectedDate
        affectedDates = self.fakeReport.affectedDates.map {
            FakeReportDate().apply {
                affectedDate = it
            }
        }
    }
}

fun ChangeRequest.bankruptcy(): Bankruptcy {
    val self = this@bankruptcy
    return Bankruptcy().apply {
        sign = self.bankruptcy.sign
        affectedByDefault = self.bankruptcy.affectedByDefault
        affectedDate = self.bankruptcy.affectedDate
    }
}

fun ChangeRequest.toMonitoringProcessFraudSchema(): MonitoringProcessFraudScheme {
    val self = this@toMonitoringProcessFraudSchema
    return MonitoringProcessFraudScheme().apply {
        scheme
    }
}

private fun List<Int>?.toStringFraudSchemas(): String? =
    when {
        this == null -> null
        this.isEmpty() -> null
        else -> this.toString()
    } надо тоже видимо lazy сделать package ru.sber.poirot.focus.stages.inwork.impl

import org.springframework.http.codec.multipart.FilePart
import org.springframework.stereotype.Service
import reactor.core.publisher.Flux
import ru.sber.poirot.CurrentUser
import ru.sber.poirot.engine.model.full.monitoring.FocusMonitoringRecord
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.contract.checkFields
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.AGREEMENT
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.Companion.getStatusById
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.IN_WORK
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.*
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.shared.contract.toFocusMonitoringRecord
import ru.sber.poirot.focus.shared.contract.validateTextFields
import ru.sber.poirot.focus.stages.inwork.InWorkStage
import ru.sber.poirot.focus.stages.inwork.InWorkRequest
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps
import ru.sber.poirot.suspicion.manage.SuspicionManager
import ru.sber.poirot.taskfileclient.upload.impl.SimpleTaskFileUploadManager
import ru.sber.poirot.taskfileclient.upload.impl.SimpleUploadTask

@Service
class InWorkStageImpl(
    private val focusDao: FmRecordDao,
    private val currentUser: CurrentUser,
    private val suspicionManager: SuspicionManager,
    private val uploadManager: SimpleTaskFileUploadManager,
) : InWorkStage {

    override suspend fun sendToAgreement(request: InWorkRequest, files: Flux<FilePart>) {
        request.checkFields(CONFIRMED_WITHOUT_FRAUD_SIGNS, SEND_TO_AGREEMENT_VALIDATION_FAILED)
        update(request, AGREEMENT, files)
    }

    override suspend fun save(request: InWorkRequest, files: Flux<FilePart>) {
        request.validateTextFields()
        update(request, files = files)
    }

    private suspend fun update(
        request: InWorkRequest,
        status: MonitoringStatus? = null,
        files: Flux<FilePart>,
    ) {
        val login = currentUser.userName()
        val recordToUpdate = recordToUpdate(request, login, status)
        val fraudSchemes = fraudSchemeCorps.asSet().toList()

        uploadFiles(files, recordToUpdate)

        suspicionManager.persist(
            recordToUpdate.id.toString(),
            request.suspicions.suspicions(fraudSchemes).suspicionEntities()
        ) { focusDao.mergeWithChildren(recordToUpdate) }
    }

    private suspend fun recordToUpdate(
        request: InWorkRequest,
        login: String,
        status: MonitoringStatus?,
    ): FocusMonitoringRecord {
        val record = focusDao.findRecordBy(request.recordId, listOf(IN_WORK.id), login)
            ?: throw FrontException(RECORD_STATUS_HAS_CHANGED)

        if (request.suspicions.les.any { it.inn == record.inn }) {
            throw FrontException(SUSPICIONS_CONTAINS_MAIN_INN)
        }

        return request.toFocusMonitoringRecord(record, status)
    }

    private suspend fun uploadFiles(files: Flux<FilePart>, recordToUpdate: FocusMonitoringRecord): Unit =
        uploadManager.upload(
            SimpleUploadTask(
                taskId = recordToUpdate.id.toString(),
                key = recordToUpdate.inn ?: throw FrontException(INN_NOT_SPECIFIED_FOR_FILES),
                status = getStatusById(recordToUpdate.status)?.status
                    ?: throw FrontException(NOT_FOUND_MONITORING_STATUS)
            ),
            files
        )
}package ru.sber.poirot.focus.stages.inwork

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE
import org.springframework.http.codec.multipart.FilePart
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import reactor.core.publisher.Flux
import ru.sber.permissions.focus.HAS_BASKET_FOCUS_MONITORING_AND_STATUS_IN_WORK_FM
import ru.sber.poirot.audit.AuditClient

@RestController
@RequestMapping("/api/inwork")
@Tag(
    name = "inWork",
    description = "для задач в статсуе - \"В работе\""
)
class InWorkController(
    private val auditClient: AuditClient,
    private val inWorkStage: InWorkStage
) {

    @PostMapping("/send-to-agreement", consumes = [MULTIPART_FORM_DATA_VALUE])
    @PreAuthorize(HAS_BASKET_FOCUS_MONITORING_AND_STATUS_IN_WORK_FM)
    @Operation(summary = "Отправить на согласование")
    suspend fun sendToAgreement(
        @RequestPart(name = "data")
        @Schema(description = "Данные из объекта InWorkRequest")
        request: InWorkRequest,
        @RequestPart(required = false)
        @Schema(description = "Новые прикрепленные файлы по фокусному мониторингу")
        files: Flux<FilePart>
    ): Unit = auditClient.audit(event = "FOCUS_RECORD_SEND_TO_AGREEMENT", details = "recordId = ${request.recordId}") {
        inWorkStage.sendToAgreement(request, files)
    }

    @PostMapping("/save", consumes = [MULTIPART_FORM_DATA_VALUE])
    @PreAuthorize(HAS_BASKET_FOCUS_MONITORING_AND_STATUS_IN_WORK_FM)
    @Operation(summary = "Сохранить информацию о задаче фокусного мониторинга")
    suspend fun save(
        @RequestPart(name = "data")
        @Schema(description = "Данные из объекта InWorkRequest")
        request: InWorkRequest,
        @RequestPart(required = false)
        @Schema(description = "Новые прикрепленные файлы по фокусному мониторингу")
        files: Flux<FilePart>
    ): Unit = auditClient.audit(event = "FOCUS_RECORD_CHANGED", details = "recordId = ${request.recordId}") {
        inWorkStage.save(request, files)
    }
}
