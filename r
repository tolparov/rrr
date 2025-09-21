package ru.sber.poirot.focus.upload.manual.uploader.collect

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

        innToStatuses.forEach { (inn, statuses) ->
            val req = innToRequest[inn] ?: return@forEach
            val activeStatuses = statuses.filter { it !in setOf(AGREED.id, DELETED.id) }

            val hasConflict = when (req.processType) {
                11 -> activeStatuses.any { it.processType == 11 }
                else -> activeStatuses.any { it.processType != 11 }
            }

            if (hasConflict) submitErrorFor(inn, HAS_FOCUS_MONITORING_RECORD)
        }
    }

    private fun defaultsFrom(
        inns: List<String>,
        defaultInfos: List<DefaultInfo>,
        generalInfos: List<GeneralClientInfo>
    ): List<Default> {
        val innToDefaultInfo = defaultInfos.associateBy { it.inn }
        val innToClientInfo = generalInfos.associateBy { it.inn }

        return inns.mapNotNull { inn ->
            val defaultInfo = innToDefaultInfo[inn]
            val clientInfo = innToClientInfo[inn]
            val req = innToRequest[inn]

            if (hasNoErrorsFor(inn)) {
                if (req != null && req.processType == 11 && req.slaByDefault == null) {
                    submitErrorFor(inn, SLA_BY_DEFAULT_REQUIRED)
                    return@mapNotNull null
                }

                Default(
                    defaultInfo = defaultInfo,
                    clientInfo = clientInfo!!,
                    processType = innToProcessType[inn]!!,
                    slaByDefault = req?.slaByDefault,
                    initiatorComment = req?.initiatorComment
                )
            } else null
        }
    }

    private fun defaultInfosFrom(
        clientInfos: List<DefaultClientInfo>,
        eventInfos: List<DefaultEventInfo>
    ): List<DefaultInfo> {
        val innToDefaultEvent = eventInfos.associateBy { it.inn }

        return clientInfos.map { client ->
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
    }

    private fun List<GeneralClientInfo>.submitErrors() {
        filter { it.isCorpCompanyNull }.mapNotNull { it.inn }
            .forEach { inn -> submitErrorFor(inn, CORP_COMPANY_NOT_FOUND) }
    }

    private fun getErrors(): List<UploadError> =
        getKeyToErrors().map { (inn, errors) ->
            UploadError(inn, innToProcessType[inn] ?: -1, errors)
        }
}package ru.sber.poirot.focus.upload.manual.uploader.collect.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.focusMonitoringRecord
import ru.sber.poirot.focus.upload.manual.uploader.UploaderImpl.Companion.manualLoadLog
import ru.sber.poirot.utils.withMeasurement

@Repository
class DslCollectorDao : CollectorDao {
    override suspend fun findInnToStatuses(inns: List<String>): Map<String, List<Pair<Int?, Int>>> =
        withMeasurement("Found inn to status by inns", logger = manualLoadLog, constraintInMs = 100) {
            (findAll(entity = focusMonitoringRecord, batch = false) fetchFields {
                listOf(inn, status, processType)
            } where {
                focusMonitoringRecord.inn `in` inns
            }).groupBy(
                keySelector = { it.inn },
                valueTransform = { it.status to it.processType }
            )
        }
}
