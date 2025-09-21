. Изменения на стороне сервиса focus-monitoring
3.1 Изменения в АПИ
Доработать АПИ - добавить +3 поля slaByDefault, initiatorComment и monitoringProcessFraudSchemas в большинство АПИ, подробнее см. в п4 "Контракт OpenAPI"
Логика заполнения атрибутов в доработанных ответах АПИ:см. выше аналогично AnalyzeRecord.initiatorCommentАПИПоле в АПИКак заполнять/focus-monitoring/api/dictsDictionaryDto.slaByDefault.keyre_dictionaries.monitoring_sla_by_default.idDictionaryDto.slaByDefault.value<re_dictionaries.monitoring_sla_by_default.duration_in_minutes, преобразованное в часы> + " ч."Например,:для duration_in_minutes = 330, должно вернуться "5.5 ч."
для duration_in_minutes = 480, должно вернуться "8 ч."
/focus-monitoring/api/analyze-list/recordsAnalyzeRecord.slaByDefault<focus_monitoring.focus_monitoring_record.sla_by_default_in_minutes>, преобразованное в часы> + " ч."Например,:для duration_in_minutes = 330, должно вернуться "5.5 ч."
для duration_in_minutes = 480, должно вернуться "8 ч."
AnalyzeRecord.initiatorCommentfocus_monitoring.focus_monitoring_record.initiatorComment/focus-monitoring/api/registry/recordsRegistryRecord.slaByDefaultсм. выше аналогично AnalyzeRecord.slaByDefaultRegistryRecord.initiatorCommentсм. выше аналогично AnalyzeRecord.initiatorComment/focus-monitoring/api/basket/recordsBasketRecord.slaByDefaultсм. выше аналогично AnalyzeRecord.slaByDefaultBasketRecord.initiatorCommentсм. выше аналогично AnalyzeRecord.initiatorComment/focus-monitoring/api/view/record/{source}/{recordId}ViewRecord.slaByDefaultсм. выше аналогично AnalyzeRecord.slaByDefaultViewRecord.initiatorComment
Изменения в логике АПИ /focus-monitoring/api/inwork/send-to-agreement:
сохранять массив InWorkRequest.monitoringProcessFraudSchemas в БД в таблицу focus_monitoring.monitoring_process_fraud_schemefocus_monitoring.monitoring_process_fraud_scheme.full_commentиз запроса апи InWorkRequest.monitoringProcessFraudSchemas.fullCommentfocus_monitoring.monitoring_process_fraud_scheme.short_commentиз запроса апи InWorkRequest.monitoringProcessFraudSchemas.shortCommentfocus_monitoring.monitoring_process_fraud_scheme.idТехнический id, автоинкрементfocus_monitoring.monitoring_process_fraud_scheme.focus_monitoring_record_idВнешний ключ на задачуfocus_monitoring.focus_monitoring_record.idfocus_monitoring.monitoring_process_fraud_scheme.schemeБерем из запроса АПИ InWorkRequest.monitoringProcessFraudSchemas.fraudSchemeId
Находим соответствующую запись из справочника re_dictionaries.fraud_reasons_corp по id =fraudSchemeId
Используем re_dictionaries.fraud_reasons_corp.key
если записей ранее не было, то вставляем записи из запроса, если были, то удаляем все записи по задаче и добавляем записи из запроса

Изменения в логике АПИ /focus-monitoring/api/upload/uploadByInn:TODO инициировать ДИС с уникальными параметрами бизнес-линии

Изменение в логике АПИ <отправка на согласование> - TODO: описать сохранение данных в re_fraud
Заполнение фрод-признаков:
1.9 Заполнение fraudList (фрод-признака) по завершению процедуры ФМ
Тип реестрабез изменений?"ЮЛ:КлиентОрганизация"Объект проверкибез изменений?ИНН из задачиПризнак мошенничествабез изменений?"Позозрение"Причина проставлениябез изменений?Схема из задачиИсточникбез изменений?"Мониторинг"Комментарийбез изменений?Полный коммент из задачи  Короткий комментарийбез изменений?Краткий коммент из задачи  Тип фродабез изменений?"Последующий"Режим контролябез изменений?"Off-line"
3. Изменения на стороне сервиса dis-pro
4. Контракт OpenAPI
OpenAPI
Изменения можно посмотреть сравнив v2 (новое) с v1 (как сейчас) по ссылке: https://apistudio-iamosh.sigma.sbrf.ru/#/projects/13269/specs/swagger/77656/140815/versions/diff/140815/140680 :
в рамках п1.1, п1.4 и п1.5 появились +2 поля slaByDefault и initiatorComment в след. эндпоинтах:в запросе /focus-monitoring/api/upload/verifyEGRULByInn
в запросе /focus-monitoring/api/upload/verifyDefaultByInn - сейчас помоги мне сделать эти изменения
в запросе /focus-monitoring/api/upload/uploadByInn- сейчас помоги мне сделать эти изменения
в ответе /focus-monitoring/api/analyze-list/records- сейчас помоги мне сделать эти изменения
в ответе /focus-monitoring/api/dicts
в ответе /focus-monitoring/api/registry/records
в ответе /focus-monitoring/api/basket/records
в ответе /focus-monitoring/api/view/record/{source}/{recordId}
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
}package ru.sber.poirot.focus.upload.manual


class UploadRequest(
    val inn: String,
    val processType: Int,
    val slaByDefault: Int?,
    val initiatorComment: String?,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as UploadRequest

        if (inn != other.inn) return false

        return true
    }

    override fun hashCode(): Int {
        return inn.hashCode()
    }
}package ru.sber.poirot.focus.upload.manual

import io.swagger.v3.oas.annotations.media.Schema

enum class VerifyDefaultStatus {
    @Schema(description = "Валидация ИНН пройдена успешно")
    SUCCESS,

    @Schema(description = "Для ИНН отсутствуют данные о дефолтах")
    DEFAULTS_MISSING;

    companion object {
        fun from(boolean: Boolean): VerifyDefaultStatus = when (boolean) {
            true -> SUCCESS
            false -> DEFAULTS_MISSING
        }
    }
}package ru.sber.poirot.focus.upload.manual

import io.swagger.v3.oas.annotations.media.Schema

enum class VerifyEgrulStatus {
    @Schema(description = "Валидация ИНН пройдена успешно")
    SUCCESS,

    @Schema(description = "ИНН не найден в ЕГРЮЛ")
    EGRUL_MISSING;

    class EgrulNotFound : Exception("EGRUL info not found")
}package ru.sber.poirot.focus.upload.manual

import java.util.*

private val base64Encoder: Base64.Encoder = Base64.getEncoder()

class UploadResponse(
    val fileName: String,
    val success: Int,
    val failed: Int,
    file: ByteArray,
) {
    val file = base64Encoder.encodeToString(file)
    val size: Int = success + failed
}package ru.sber.poirot.focus.upload.manual.uploader.collect.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.focusMonitoringRecord
import ru.sber.poirot.focus.upload.manual.uploader.UploaderImpl.Companion.manualLoadLog
import ru.sber.poirot.utils.withMeasurement

@Repository
class DslCollectorDao : CollectorDao {
    override suspend fun findInnToStatuses(inns: List<String>): Map<String, List<Int?>> =
        withMeasurement("Found inn to status by inns", logger = manualLoadLog, constraintInMs = 100) {
            (findAll(entity = focusMonitoringRecord, batch = false) fetchFields {
                listOf(inn, status)
            } where {
                focusMonitoringRecord.inn `in` inns
            }).groupBy({ it.inn }, { it.status })
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

            if (hasNoErrorsFor(inn))
                return@mapNotNull Default(
                    defaultInfo = defaultInfo,
                    clientInfo = clientInfo!!,
                    processType = innToProcessType[inn]!!
                )
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
}package ru.sber.poirot.focus.upload.manual.uploader.collect

import ru.sber.poirot.focus.upload.general.Default
import ru.sber.poirot.focus.upload.manual.uploader.UploadError

class CollectResult(
    val correct: List<Default>,
    val rejected: Collection<UploadError>
) {
    companion object {
        val EmptyCollectResult = CollectResult(emptyList(), emptyList())
    }
}package ru.sber.poirot.focus.upload.general

import ru.sber.poirot.engine.model.full.monitoring.FocusMonitoringRecord
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.INITIATION
import java.time.LocalDate
import java.time.LocalDateTime.now

class Default(
    val defaultInfo: DefaultInfo?,
    val clientInfo: GeneralClientInfo,
    val processType: Int
)

class DefaultInfo(
    val aspId: Long?,
    val eventId: Long?,
    val name: String?,
    val inn: String,
    val clientId: String?,
    val beginDate: LocalDate?,
    val defaultType: String?,
    val segment: String? = null
)

data class DefaultClientInfo(
    val inn: String,
    val name: String?,
    val clientId: String?,
    val segment: String? = null
)

data class DefaultEventInfo(
    val aspId: Long,
    val eventId: Long,
    val inn: String,
    val beginDate: LocalDate?,
    val defaultType: String?,
    val reasonName: String?,
)

class GeneralClientInfo(
    val inn: String?,
    val isCorpCompanyNull: Boolean,
    val clientId: String?,
    val epkId: String?,
    val opf: String?,
    val name: String?,
    val segment: String?,
    val riskSegment: String?,
    val macroIndustry: String?,
    val gre: String?,
    val consGroupName: String?,
    val dateLastContract: LocalDate?,
    val dateCurrentDelay: LocalDate?,
    val dateNpl90: LocalDate?,
    val clientDivision: String?,
) {
    companion object {
        val EmptyClientInfo = GeneralClientInfo(
            inn = null,
            isCorpCompanyNull = true,
            clientId = null,
            epkId = null,
            name = null,
            segment = null,
            opf = null,
            riskSegment = null,
            macroIndustry = null,
            gre = null,
            consGroupName = null,
            dateLastContract = null,
            dateCurrentDelay = null,
            dateNpl90 = null,
            clientDivision = null,
        )
    }
}

fun Default.toFocusMonitoringRecord(
    inputSource: InputSource,
    initiator: String
): FocusMonitoringRecord {
    val self = this@toFocusMonitoringRecord

    return FocusMonitoringRecord().apply {
        aspId = defaultInfo?.aspId
        eventId = defaultInfo?.eventId
        this.inputSource = inputSource.id
        processType = self.processType
        dateCreate = now()
        opf = clientInfo.opf
        clientId = clientInfo.clientId
        epkId = clientInfo.epkId
        name = clientInfo.name
        inn = clientInfo.inn
        segment = self.defaultInfo?.segment ?: clientInfo.segment
        riskSegment = clientInfo.riskSegment
        macroIndustry = clientInfo.macroIndustry
        gre = clientInfo.gre
        consGroupName = clientInfo.consGroupName
        status = INITIATION.id
        this.initiator = initiator
        beginDate = defaultInfo?.beginDate
        defaultType = defaultInfo?.defaultType
        dateLastContract = clientInfo.dateLastContract
        dateCurrentDelay = clientInfo.dateCurrentDelay
        dateNpl90 = clientInfo.dateNpl90
        clientDivision = clientInfo.clientDivision
    }
}package ru.sber.poirot.focus.upload.manual.uploader.collect

import org.springframework.stereotype.Service
import ru.sber.poirot.focus.upload.manual.UploadRequest
import ru.sber.poirot.focus.upload.manual.uploader.collect.CollectResult.Companion.EmptyCollectResult
import ru.sber.poirot.focus.upload.manual.uploader.collect.dao.CollectorDao
import ru.sber.poirot.focus.upload.manual.uploader.fetch.DefaultInfoDao
import ru.sber.poirot.focus.upload.manual.uploader.onErrorWithSingleLoad
import ru.sber.poirot.focus.upload.general.GeneralInfoProvider


@Service
class DefaultCollectorImpl(
    private val defaultInfoDao: DefaultInfoDao,
    private val collectorDao: CollectorDao,
    private val generalInfoProvider: GeneralInfoProvider,
) : DefaultCollector {
    override suspend fun collect(request: UploadRequest): CollectResult {
        val process = collectingProcess(listOf(request), onErrorWithSingleLoad)
        return process.collect()
    }

    override suspend fun collectAll(requests: List<UploadRequest>): CollectResult {
        if (requests.isEmpty()) return EmptyCollectResult
        val process = collectingProcess(requests)
        return process.collect()
    }

    private fun collectingProcess(
        requests: List<UploadRequest>,
        onError: (UploadErrorType) -> Unit = { }
    ): CollectingProcess = CollectingProcess(
        requests,
        defaultInfoDao,
        collectorDao,
        generalInfoProvider,
        onError
    )
}package ru.sber.poirot.focus.upload.manual.uploader.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.coroutines.toList
import ru.sber.poirot.engine.dsl.Order.DESC
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.dsl.invoke
import ru.sber.poirot.engine.dsl.queries.batch.executeInBatchContext
import ru.sber.poirot.engine.metamodel.company
import ru.sber.poirot.engine.metamodel.defaultClient
import ru.sber.poirot.engine.metamodel.defaultEvent
import ru.sber.poirot.focus.upload.general.DefaultClientInfo
import ru.sber.poirot.focus.upload.general.DefaultEventInfo
import ru.sber.poirot.focus.upload.manual.uploader.UploaderImpl.Companion.manualLoadLog
import ru.sber.poirot.utils.withMeasurement

@Repository
class DslDefaultInfoDao : DefaultInfoDao {
    override suspend fun findDefaultClientInfosBy(inns: List<String>): List<DefaultClientInfo> {
        return withMeasurement("Found default client infos by inns", logger = manualLoadLog, constraintInMs = 100) {
            val defaultClients = findAll(
                fields = listOf(defaultClient.inn, defaultClient.clientId),
                distinctOn = listOf(defaultClient.inn),
                orderBy = listOf(defaultClient.inn, defaultClient.beginDate),
                order = DESC,
                batch = false
            ) where {
                defaultClient {
                    inn `in` inns
                    endDate.isNull()
                }
            } convertTo {
                nextField<String>() to nextField<String?>()
            }

            defaultClients.executeInBatchContext(results = toList()) { (inn, id), _ ->
                val companyByInn = findFirst(company.fullName) where {
                    company.category `=` "Головная организация"
                    company.inn `=` inn
                }
                DefaultClientInfo(
                    inn = inn,
                    name = companyByInn,
                    clientId = id
                )
            }
        }
    }

    override suspend fun findDefaultEventInfosBy(inns: List<String>): List<DefaultEventInfo> =
        withMeasurement("Found default infos by inns", logger = manualLoadLog, constraintInMs = 100) {
            (findAll(
                fields = listOf(
                    defaultEvent.aspId,
                    defaultEvent.eventId,
                    defaultClient.inn,
                    defaultEvent.beginDate,
                    defaultEvent.defaultType,
                    defaultEvent.reasonName
                ),
                orderBy = listOf(defaultEvent.beginDate),
                order = DESC,
                batch = false
            ) join {
                defaultClient.aspId `=` defaultEvent.aspId
            } where {
                defaultEvent {
                    defaultClient.inn `in` inns
                    endDate.isNull()
                    //defaultType `not in` listOf("LIQUIDATION", "BANKRUPTCY").inlined // todo temporary
                }
            }).distinctBy { defaultClient.inn }.convertTo {
                DefaultEventInfo(
                    aspId = nextField(),
                    eventId = nextField(),
                    inn = nextField(),
                    beginDate = nextField(),
                    defaultType = nextField(),
                    reasonName = nextField()
                )
            }
        }
}package ru.sber.poirot.focus.upload.manual.uploader.validate

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.ibRegInfoEgrul
import ru.sber.poirot.engine.metamodel.leRegInfoEgrul
import ru.sber.poirot.focus.upload.manual.uploader.UploadRequestWrapper
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType.INN_NOT_FOUND_REG_INFO_EGRUL

@Service
class EgrulInnValidatorImpl : InnValidator {
    override suspend fun validateAll(
        wrappers: List<UploadRequestWrapper>,
        onError: (errorType: UploadErrorType) -> Unit
    ) {
        existIbOrLeRegInfoEgrul(wrappers, onError)
    }

    private suspend fun existIbOrLeRegInfoEgrul(
        wrappers: List<UploadRequestWrapper>,
        onError: (errorType: UploadErrorType) -> Unit
    ) {
        val inns = wrappers.map { it.inn }
        val ibExisted = ibRegInfoEgrulInns(inns)
        val leExisted = leRegInfoEgrulInns(inns)

        wrappers.forEach {
            val inn = it.inn
            if (!(ibExisted).contains(inn) && !leExisted.contains(inn)) {
                it.errors.add(INN_NOT_FOUND_REG_INFO_EGRUL)
                onError(INN_NOT_FOUND_REG_INFO_EGRUL)
            }
        }
    }

    private suspend fun ibRegInfoEgrulInns(inns: List<String>): Set<String> =
        (findAll(listOf(ibRegInfoEgrul.inn)) where {
            ibRegInfoEgrul.inn `in` inns
        }).convertTo { nextField<String>() }.toSet()

    private suspend fun leRegInfoEgrulInns(inns: List<String>): Set<String> =
        (findAll(listOf(leRegInfoEgrul.inn)) where {
            leRegInfoEgrul.inn `in` inns
        }).convertTo { nextField<String>() }.toSet()
}package ru.sber.poirot.focus.upload.manual.uploader.validate

import org.springframework.stereotype.Service
import ru.sber.poirot.focus.upload.manual.VerifyDefaultStatus
import ru.sber.poirot.focus.upload.manual.uploader.fetch.DefaultInfoDao

@Service
class EventValidatorImpl(private val defaultInfoDao: DefaultInfoDao) : EventValidator {
    override suspend fun validate(inn: String): VerifyDefaultStatus {
        val clients = defaultInfoDao.findDefaultClientInfosBy(listOf(inn))
        val events = defaultInfoDao.findDefaultEventInfosBy(listOf(inn))

        return VerifyDefaultStatus.from(clients.isNotEmpty() && events.isNotEmpty())
    }
}
