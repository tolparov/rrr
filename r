package ru.sber.poirot.focus.stages

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.inProcessFraudsCache
import ru.sber.poirot.focus.shared.dictionaries.model.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudCode.SUSPICION
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.Companion.fraudSchemes
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.fraud.client.KtorFraudClient
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.fraud.model.FraudRegistryType
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
                    inProcessFraud = inProcessFraudsByCode[it.new.inProcessFraud],
                    previousExecutor = it.previous.executor

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
        previousExecutor: String? = null
    ): List<FraudRecord> {
        val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
        val fraudReasonsCorpsDbList = fraudReasonsCorp.associate { it.key to it.id }
        val fraudReasonsCorpsEnumList = FraudScheme.fraudSchemeIdByCode

        val mergedFraudReasons = fraudReasonsCorpsDbList + fraudReasonsCorpsEnumList

        return if (processType == 11 && !monitoringProcessFraudSchemas.isNullOrEmpty()) {
            val monitoringFrauds = monitoringProcessFraudSchemas.map { scheme ->
                val fraudScheme = mergedFraudReasons.entries.firstOrNull { it.value == scheme.fraudSchemeId }?.key ?: throw FrontException("id=$id fraudSchemeId=${scheme.fraudSchemeId}")
                FraudRecord.fraudRecord(
                    type = FraudRegistryType.LE_CLIENT.type,
                    key = inn!!,
                    keyNoApp = inn,
                    fraudStatus = SUSPICION.code,
                    scheme = fraudScheme ,
                    source = "monitoring_ksb",
                    fullComment = scheme.fullComment ?: summary,
                    shortComment = scheme.shortComment ?: summaryKp,
                    login = executor,
                    dateTime = LocalDateTime.now(),
                    typeFraud = "Последующий",
                    incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                    corpControlMode = fmFraudCorpControlMode,
                    fraudAdditionalInfo = null
                )
            }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                gfmFraudSource,
                executor ?: previousExecutor ?: throw FrontException("Исполнитель должен быть назначен"),
                gfmTypeFraud
            )

            (monitoringFrauds + fraudsBySuspicions).distinct()
        } else {
            val generalFrauds = fraudSchemes.mapNotNull { it.fraudRecord(this, canBeDeleted, inProcessFraud) }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                fmFraudSource,
                fmFraudLogin,
                typeFraud(inProcessFraud)
            )
            (generalFrauds + fraudsBySuspicions).distinct()
        }
    }

    private fun FmRecord.fraudRecordsBySuspicions(
        fraudSchemes: List<FraudReasonsCorp>,
        source: String?,
        login: String,
        typeFraud: String?
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
                source = source,
                fullComment = summary,
                shortComment = summaryKp,
                login = login,
                dateTime = LocalDateTime.now(),
                typeFraud = typeFraud,
                incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                corpControlMode = fmFraudCorpControlMode,
                fraudAdditionalInfo = null,
            )
        }
}
