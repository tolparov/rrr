Изменения в логике АПИ /focus-monitoring/api/upload/uploadByInn:
сохранять новые поля из запроса в БД:

focus_monitoring.focus_monitoring_record.sla_by_default_in_minutes	
Берем из запроса АПИ UploadRequest.slaByDefault 
Находим соответствующую запись из справочника re_dictionaries.monitoring_sla_by_default по id = UploadRequest.slaByDefault И process_name = <UploadRequest.processType, преобразованное в имя>
Используем re_dictionaries.monitoring_sla_by_default.duration_in_minutes
focus_monitoring.focus_monitoring_record.initiator_сomment	из запроса АПИ UploadRequest.initiatorComment
доработать блокировку на создание на задач-дубликатов:
сейчас так: проверяются только задачи до статуса согласовано (код 7), задачей-дубликатом является 1 ИНН.
Т.е. максимум можно завести 1 задачу на 1 ИНН
надо так: проверяются только задачи до статуса согласовано (код 7), задачей-дубликатом является 1 ИНН И принадлежность процесса задачи к мониторингу default_process_type.monitoring_process. 
Т.е. максимум можно завести 2 задачи на 1 ИНН: одну с monitoring_process = false (старый ФМ), одну с monitoring_process = true.
package ru.sber.poirot.focus.upload.manual

import org.springframework.http.codec.multipart.FilePart
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.web.bind.annotation.*
import ru.sber.permissions.focus.HAS_INITIATION_FOCUS_MONITORING
import ru.sber.poirot.audit.AuditClient

@RestController
@RequestMapping("api/upload")
class UploadController(
    private val auditClient: AuditClient,
    private val uploader: Uploader,
) {
    @PostMapping("/verifyEGRULByInn")
    @PreAuthorize(HAS_INITIATION_FOCUS_MONITORING)
    suspend fun verifyEgrulByInn(@RequestBody request: UploadRequest): VerifyEgrulStatus =
        auditClient.audit(event = "FOCUS_VERIFY_EGRUL_BY_INN", details = "request: $request") {
            return@audit uploader.verifyEgrulByInn(request)
        }

    @PostMapping("/verifyDefaultByInn")
    @PreAuthorize(HAS_INITIATION_FOCUS_MONITORING)
    suspend fun verifyDefaultByInn(@RequestBody request: UploadRequest): VerifyDefaultStatus =
        auditClient.audit(event = "FOCUS_VERIFY_UPLOAD_BY_INN", details = "request: $request") {
            return@audit uploader.verifyDefaultByInn(request)
        }

    @PostMapping("/uploadByInn")
    @PreAuthorize(HAS_INITIATION_FOCUS_MONITORING)
    suspend fun uploadByInn(@RequestBody request: UploadRequest): Unit =
        auditClient.audit(event = "FOCUS_UPLOAD_BY_INN", details = "request: $request") {
            uploader.upload(request)
        }

    @PostMapping("/uploadByFile")
    @PreAuthorize(HAS_INITIATION_FOCUS_MONITORING)
    suspend fun uploadByFile(@RequestPart file: FilePart): UploadResponse =
        auditClient.audit(event = "FOCUS_UPLOAD_INNS_FILE") {
            uploader.uploadByFile(file)
        }
}package ru.sber.poirot.focus.upload.manual.uploader

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.codec.multipart.FilePart
import org.springframework.stereotype.Service
import ru.sber.poirot.CurrentUser
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource.MANUAL
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.upload.general.Default
import ru.sber.poirot.focus.upload.general.toFocusMonitoringRecord
import ru.sber.poirot.focus.upload.manual.*
import ru.sber.poirot.focus.upload.manual.VerifyEgrulStatus.EgrulNotFound
import ru.sber.poirot.focus.upload.manual.uploader.collect.DefaultCollector
import ru.sber.poirot.focus.upload.manual.uploader.parse.RequestParser
import ru.sber.poirot.focus.upload.manual.uploader.reject.RejectFilePreparer
import ru.sber.poirot.focus.upload.manual.uploader.validate.EventValidator
import ru.sber.poirot.focus.upload.manual.uploader.validate.InnValidator

@Service
class UploaderImpl(
    private val parser: RequestParser,
    private val innValidator: InnValidator,
    private val eventValidator: EventValidator,
    private val rejectFilePreparer: RejectFilePreparer,
    private val defaultCollector: DefaultCollector,
    private val focusDao: FmRecordDao,
    private val currentUser: CurrentUser
) : Uploader {
    override suspend fun verifyEgrulByInn(request: UploadRequest): VerifyEgrulStatus {
        val result = runCatching { innValidator.validate(request.wrap(), onError = { throw EgrulNotFound() }) }
        return when {
            result.exceptionOrNull() is EgrulNotFound -> VerifyEgrulStatus.EGRUL_MISSING
            else -> VerifyEgrulStatus.SUCCESS
        }
    }

    override suspend fun verifyDefaultByInn(request: UploadRequest): VerifyDefaultStatus =
        eventValidator.validate(request.inn)

    override suspend fun upload(request: UploadRequest) {
        val defaults = defaultCollector.collect(request).correct
        doUpload(defaults)
    }

    override suspend fun uploadByFile(file: FilePart): UploadResponse {
        val (clear, rejected) = parser.parse(file)
            .partition { it.hasNoError() }

        val result = defaultCollector.collectAll(clear.map { it.request })
        doUpload(result.correct)
        val errors = rejected.asUploadErrors() + result.rejected
        val rejectedFile = rejectFilePreparer.prepare(errors)

        return UploadResponse(
            fileName = file.filename(),
            success = result.correct.size,
            failed = errors.size,
            file = rejectedFile
        )
    }

    private suspend fun doUpload(defaults: List<Default>) {
        val login = currentUser.userName()
        val records = defaults.map { it.toFocusMonitoringRecord(MANUAL, login) }
        focusDao.insert(records)
    }

    companion object {
        val manualLoadLog: Logger = LoggerFactory.getLogger("ManualLoadLogger")
    }
}package ru.sber.poirot.focus.upload.manual.uploader.collect

import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.AGREED
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.DELETED
import ru.sber.poirot.focus.upload.general.*
import ru.sber.poirot.focus.upload.manual.UploadRequest
import ru.sber.poirot.focus.upload.manual.uploader.UploadError
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType.*
import ru.sber.poirot.focus.upload.manual.uploader.collect.dao.CollectorDao
import ru.sber.poirot.focus.upload.manual.uploader.fetch.DefaultInfoDao

class CollectingProcess(
    private val requests: List<UploadRequest>,
    private val defaultInfoDao: DefaultInfoDao,
    private val collectorDao: CollectorDao,
    private val generalInfoProvider: GeneralInfoProvider,
    onError: (UploadErrorType) -> Unit = { }
) : ErrorHolder<String, UploadErrorType>(onError) {

    private val innToProcessType: Map<String, Int> = requests.associateBy({ it.inn }) { it.processType }
    private val innToRequest: Map<String, UploadRequest> = requests.associateBy { it.inn }

    suspend fun collect(): CollectResult {
        val inns = requests.map { it.inn }
        checkExistedFmRecordsBy(inns)

        val events = collectEvents(requests)

        val generalClientInfos = generalInfoProvider.fetchClientInfosBy(inns, events)
        generalClientInfos.submitErrors()
        val defaults = defaultsFrom(inns, events, generalClientInfos)

        return CollectResult(defaults, getErrors())
    }

    private suspend fun collectEvents(requests: List<UploadRequest>): List<DefaultInfo> {
        val inns = requests.map { it.inn }
        val clients = defaultInfoDao.findDefaultClientInfosBy(inns)
        val clientInns = clients.map { it.inn }
        val events = defaultInfoDao.findDefaultEventInfosBy(clientInns)

        return defaultInfosFrom(clients, events)
    }

    private suspend fun checkExistedFmRecordsBy(inns: List<String>) {
        val innToStatuses = collectorDao.findInnToStatuses(inns)

        innToStatuses.filter { (_, statuses) ->
            statuses.any { it !in setOf(AGREED.id, DELETED.id) }
        }.forEach { (inn, _) ->
            submitErrorFor(inn, HAS_FOCUS_MONITORING_RECORD)
        }
    }

    private fun defaultsFrom(
        inns: List<String>,
        defaultInfos: List<DefaultInfo>,
        generalInfos: List<GeneralClientInfo>
    ): List<Default> {
        val innToDefaultInfo = defaultInfos.associateBy { it.inn }
        val innToClientInfo = generalInfos.associateBy { it.inn }
        val defaults = inns.mapNotNull { inn ->
            val defaultInfo = innToDefaultInfo[inn]
            val clientInfo = innToClientInfo[inn]

            if (hasNoErrorsFor(inn)) {
                val req = innToRequest[inn]
                return@mapNotNull Default(
                    defaultInfo = defaultInfo,
                    clientInfo = clientInfo!!,
                    processType = innToProcessType[inn]!!,
                    slaByDefault = req?.slaByDefault,
                    initiatorComment = req?.initiatorComment
                )
            }
            null
        }
        return defaults
    }

    private fun defaultInfosFrom(
        clientInfos: List<DefaultClientInfo>,
        eventInfos: List<DefaultEventInfo>
    ): List<DefaultInfo> {
        val innToDefaultEvent = eventInfos.associateBy { it.inn }

        val defaultInfos = clientInfos.map { client ->
            val event = innToDefaultEvent[client.inn]

            DefaultInfo(
                aspId = event?.aspId,
                eventId = event?.eventId,
                name = client.name,
                inn = client.inn,
                clientId = client.clientId,
                beginDate = event?.beginDate,
                defaultType = event?.defaultType,
            )
        }

        return defaultInfos
    }

    private fun List<GeneralClientInfo>.submitErrors() {
        filter { it.isCorpCompanyNull }.mapNotNull { it.inn }
            .forEach { inn -> submitErrorFor(inn, CORP_COMPANY_NOT_FOUND) }
    }

    private fun getErrors(): List<UploadError> =
        getKeyToErrors().map { (inn, errors) ->
            UploadError(inn, innToProcessType[inn] ?: -1, errors)
        }
}
