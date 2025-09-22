22.09 18:17:48.604 ERROR [Dispatcher-worker-1] a.w.r.e.AbstractErrorWebExceptionHandler: [fcd9f0a2-3603]  500 Server Error for HTTP POST "/api/agreement/agree/616003"

java.util.NoSuchElementException: Collection contains no element matching the predicate.
	at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException:
Error has been observed at the following site(s):
	*__checkpoint ⇢ Handler ru.sber.poirot.focus.stages.agreement.AgreementController#agree(long, Continuation) [DispatcherHandler]
	*__checkpoint ⇢ SecurityConfig$$Lambda$1307/0x0000000801ae60c0 [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthorizationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ExceptionTranslationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ LogoutWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerRequestCacheWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ SecurityContextServerWebExchangeWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ AuthenticationWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ HttpHeaderWriterWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ ServerWebExchangeReactorContextWebFilter [DefaultWebFilterChain]
	*__checkpoint ⇢ org.springframework.security.web.server.WebFilterChainProxy [DefaultWebFilterChain]
	*__checkpoint ⇢ HTTP POST "/api/agreement/agree/616003" [ExceptionHandlingWebHandler]
Original Stack Trace:
		at ru.sber.poirot.focus.stages.FmFraudManager.fraudRecords(FmFraudManager.kt:172)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds$suspendImpl(FmFraudManager.kt:30)
		at ru.sber.poirot.focus.stages.FmFraudManager.addFrauds(FmFraudManager.kt)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds$suspendImpl(FraudManager.kt:4)
		at ru.sber.poirot.fraud.client.FraudManager.addFrauds(FraudManager.kt)
		at ru.sber.poirot.focus.stages.agreement.AgreementServiceImpl$agree$2.invokeSuspend(AgreementServiceImpl.kt:39)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at kotlinx.coroutines.EventLoopImplBase.processNextEvent(EventLoop.common.kt:277)
		at kotlinx.coroutines.BlockingCoroutine.joinBlocking(Builders.kt:95)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking(Builders.kt:69)
		at kotlinx.coroutines.BuildersKt.runBlocking(Unknown Source)
		at kotlinx.coroutines.BuildersKt__BuildersKt.runBlocking$default(Builders.kt:48)
		at kotlinx.coroutines.BuildersKt.runBlocking$default(Unknown Source)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1$1.doInTransaction(Transactions.kt:26)
		at org.springframework.transaction.support.TransactionTemplate.execute(TransactionTemplate.java:140)
		at ru.sber.poirot.utils.TransactionalUtilsKt$transactionalWithReactorContext$$inlined$transactional$1.invokeSuspend(Transactions.kt:25)
		at kotlin.coroutines.jvm.internal.BaseContinuationImpl.resumeWith(ContinuationImpl.kt:33)
		at kotlinx.coroutines.DispatchedTask.run(DispatchedTask.kt:104)
		at java.base/java.util.concurrent.ForkJoinTask$RunnableExecuteAction.exec(ForkJoinTask.java:1395)
		at java.base/java.util.concurrent.ForkJoinTask.doExec(ForkJoinTask.java:373)
		at java.base/java.util.concurrent.ForkJoinPool$WorkQueue.topLevelExec(ForkJoinPool.java:1182)
		at java.base/java.util.concurrent.ForkJoinPool.scan(ForkJoinPool.java:1655)
		at java.base/java.util.concurrent.ForkJoinPool.runWorker(ForkJoinPool.java:1622)
		at java.base/java.util.concurrent.ForkJoinWorkerThread.run(ForkJoinWorkerThread.java:165)
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
        val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
        return if (processType == 11 && !monitoringProcessFraudSchemas.isNullOrEmpty()) {
            val monitoringFrauds = monitoringProcessFraudSchemas.map { scheme ->
                FraudRecord.fraudRecord(
                    type = FraudRegistryType.LE_CLIENT.type,
                    key = inn!!,
                    keyNoApp = inn,
                    fraudStatus = SUSPICION.code,
                    scheme = fraudReasonsCorp.first { it.id == scheme.fraudSchemeId }.key,
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
                executor ?: throw FrontException("Исполнитель должен быть назначен"),
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
