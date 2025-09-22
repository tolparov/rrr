package ru.sber.poirot.focus.shared.contract

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
        capitalOutflow = self.capitalOutflow()
        fakeReport = self.fakeReport()
        bankruptcy = self.bankruptcy()
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
    } надо чтоб при processType 11 сохранили только .toMonitoringProcessFraudSchema в бд остально не надо сохранять
