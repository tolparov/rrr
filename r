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
}package ru.sber.poirot.focus.shared.contract

import ru.sber.poirot.engine.model.full.monitoring.*
import ru.sber.poirot.focus.shared.contract.frauds.MonitoringProcessFraudSchema
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

        if (record.processType != 11) {
            capitalOutflow = self.capitalOutflow()
            fakeReport = self.fakeReport()
            bankruptcy = self.bankruptcy()
        }
        monitoringProcessFraudSchemes = self.monitoringProcessFraudSchemas?.toMonitoringProcessFraudSchema()
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

fun List<MonitoringProcessFraudSchema>.toMonitoringProcessFraudSchema(): List<MonitoringProcessFraudScheme> =
    this.map {
        MonitoringProcessFraudScheme().apply {
            fraudSchemeId = it.fraudSchemeId
            shortComment = it.shortComment
            fullComment = it.fullComment
        }
    }

private fun List<Int>?.toStringFraudSchemas(): String? =
    when {
        this == null -> null
        this.isEmpty() -> null
        else -> this.toString()
    } вообщем проблема что в fraudManager поподает запись у которой нет executor а для нового процесса оно нужно чтоб редактировать фрод признаки мы его получаем в переменную focusMonitpring давай перекладывать его теперь 
