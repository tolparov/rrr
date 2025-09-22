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
        val generalFrauds = fraudSchemes.mapNotNull { it.fraudRecord(this, canBeDeleted, inProcessFraud) }
        val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
        val fraudsBySuspicions = fraudRecordsBySuspicions(inProcessFraud, fraudReasonsCorp)

        return (generalFrauds + fraudsBySuspicions).distinct()
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
}
package ru.sber.poirot.focus.stages.agreement

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
}
package ru.sber.poirot.focus.stages.edit.impl

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.model.full.monitoring.FocusMonitoringRecord
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.contract.checkFields
import ru.sber.poirot.focus.shared.contract.toFocusMonitoringRecord
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.AGREED
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.*
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.focus.shared.records.model.FmRecord.Companion.toFocusRecord
import ru.sber.poirot.focus.shared.records.suspicion.SuspicionsDto
import ru.sber.poirot.focus.stages.edit.EditRequest
import ru.sber.poirot.focus.stages.edit.RecordEditor
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps
import ru.sber.poirot.suspicion.manage.SuspicionManager

@Service
class RecordEditorImpl(
    private val focusDao: FmRecordDao,
    private val suspicionManager: SuspicionManager,
    private val fraudManager: FraudManager<FmRecord>,
) : RecordEditor {

    override suspend fun edit(request: EditRequest) {
        request.checkFields(EDITED_WITHOUT_FRAUD_SIGNS, EDITED_VALIDATION_FAILED)
        val focusRecord = focusRecord(request.recordId, request.suspicions)
        val editedFmRecord = editedFmRecord(request, focusRecord)
        val fraudSchemes = fraudSchemeCorps.asSet().toList()

        suspicionManager.persist(
            request.recordId.toString(),
            focusRecord.suspicions.suspicions(fraudSchemes).suspicionEntities()
        ) {
            focusDao.mergeWithChildren(editedFmRecord)
            fraudManager.editFrauds(
                FraudManager.RecordPair(
                    new = editedFmRecord.toFocusRecord(),
                    previous = focusRecord,
                )
            )
        }
    }

    private suspend fun focusRecord(recordId: Long, suspicions: SuspicionsDto): FmRecord =
        focusDao.findRecordBy(recordId, listOf(AGREED.id))
            ?.copy(suspicions = suspicions) ?: throw FrontException(INCORRECT_STATUS, "$AGREED")

    private fun editedFmRecord(
        request: EditRequest,
        fmRecord: FmRecord,
    ): FocusMonitoringRecord {
        if (request.suspicions.les.any { it.inn == fmRecord.inn }) {
            throw FrontException(SUSPICIONS_CONTAINS_MAIN_INN)
        }

        return request.toFocusMonitoringRecord(fmRecord).apply { changed = true }
    }
} мне надо сделать развилку если тип процесса одинадцыть то фрод признаки заполняются по новой логике 
наче нужно сохранить данные в таблице с актуальными фрод-признаками re_fraud.feature (и связанных с ней) а также в таблице с историей re_fraud.feature_hist (и связанных с ней) данные по каждой схеме (1 запись в focus_monitoring.monitoring_process_fraud_scheme = 1 запись в re_fraud.feature \ feature_hist)
в актуальные таблицы данные вставляются, если их не было, либо обновляются, если записи уже существовали
в исторические таблицы всегда вставляются новые данные
логика заполнения полей в таблицах re_fraud.feature и re_fraud.feature_hist общая:
table_schema	table_name	column_name	data_type	nullable	
Как заполнять процессы ФМ с monitoring_process = false

Как заполнять процессы ФМ с monitoring_process = true

re_fraud	feature \ feature_hist	id	bigint	NOT NULL	Технический id, автоинкремент
re_fraud	feature \ feature_hist	type	varchar (100)	NOT NULL	
"ЮЛ:КлиентОрганизация" для основного клиента из задачи или ЮЛ\ИП с вкладки "Подозрительные лица"
"ЮЛ:ФИОДР" для ФЛ с вкладки "Подозрительные лица"
re_fraud	feature \ feature_hist	key	varchar (300)	NOT NULL	
focus_monitoring.focus_monitoring_record.inn для основного клиента из задачи
focus_monitoring.related_le.inn для ЮЛ\ИП с вкладки "Подозрительные лица"
related_person.last_name+'|'+related_person.first_name+'|'+related_person.second_name+'|'+related_person.birthday для ФЛ с вкладки "Подозрительные лица"
re_fraud	feature \ feature_hist	key_no_app	varchar (300)	NULL	заполнение аналогично полю key
re_fraud	feature \ feature_hist	fraud_status	varchar (100)	NULL	
"fraud" для основного клиента из задачи И если <схема>.affected_by_default = true
"suspicion" (для основного клиента из задачи И если <схема>.affected_by_default = false) ИЛИ для клиентов с вкладки "Подозрительные лица"
"suspicion" (как для основного клиента из задачи, так и для клиентов с вкладки "Подозрительные лица"

re_fraud	feature \ feature_hist	source	varchar (100)	NULL	"focus_monitoring"	"monitoring_ksb" 
re_fraud	feature \ feature_hist	scheme	varchar (250)	NOT NULL	
для основного клиента из задачи:
"fake_report" в случае схемы "Фальсификация отчетности"
"fake_doc" в случае схемы "Фальсификация документов" 
"capital_outflow" в случае схемы "Отток капитала"
"bankruptcy" в случае схемы "Преднамеренное банкротство"
для клиентов с вкладки "Подозрительные лица":
focus_monitoring.related_le.scheme для ЮЛ\ИП
focus_monitoring.related_person.scheme для ФЛ
для основного клиента из задачи:
monitoring_process_fraud_scheme.scheme
для клиентов с вкладки "Подозрительные лица":
focus_monitoring.related_le.scheme для ЮЛ\ИП
focus_monitoring.related_person.scheme для ФЛ
re_fraud	feature \ feature_hist	full_comment	varchar (33000)	NULL	focus_monitoring_record.summary	
monitoring_process_fraud_scheme.full_comment

re_fraud	feature \ feature_hist	short_comment	varchar (9000)	NULL	focus_monitoring_record.summary_kp	monitoring_process_fraud_scheme.short_comment
re_fraud	feature \ feature_hist	app_id	varchar (100)	NULL	
заполнение аналогично полю key

re_fraud	feature \ feature_hist	date_time	timestamp	NOT NULL	текущие дата-время
re_fraud	feature \ feature_hist	login	varchar (100)	NOT NULL	"autocomplete_focus_monitoring"	focus_monitoring.focus_monitoring_record.executor
re_fraud	feature \ feature_hist	type_fraud	varchar (100)	NULL	
"Преднамеренный", если focus_monitoring_record.in_process_fraud (поле "Фрод в процессе") = "Предкредитка"
"Последующий" в остальных случаях
"Последующий"

re_fraud	feature \ feature_hist	incoming_date	date	NULL	
focus_monitoring_record.date_approval

re_fraud	feature \ feature_hist	corp_control_mode	varchar (100)	NULL	"off-line"
