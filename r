package ru.sber.poirot.dpa.interaction.sender.http

import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.interaction.DpSender
import ru.sber.poirot.dpa.interaction.rqrs.DpBaseSyncResponse
import ru.sber.poirot.dpa.interaction.rqrs.DpHeadersFactory.changeSlaHeaders
import ru.sber.poirot.dpa.interaction.rqrs.DpHeadersFactory.executorRequestHeaders
import ru.sber.poirot.dpa.interaction.rqrs.DpHeadersFactory.notifyHeaders
import ru.sber.poirot.dpa.interaction.rqrs.DpHeadersFactory.reassignExecutorHeaders
import ru.sber.poirot.dpa.interaction.sender.BaseSyncSender
import ru.sber.poirot.dpa.interaction.sender.model.*
import ru.sber.poirot.dpa.interaction.sender.send
import ru.sber.poirot.dpa.interaction.sender.sendAfterExecutorRequest
import ru.sber.poirot.dpa.model.rqrs.*
import ru.sber.poirot.dpa.trace.TraceDao
import ru.sber.poirot.webclient.path.RequestParamsBuilder.Companion.requestParams

@Service
class HttpDpSender(
    @Value("\${dis.pro.svcVersion:v1}")
    private val svcVersion: String,
    @Qualifier("executorRequestSender")
    private val executorRequestSender: BaseSyncSender<DpExecutorRequest, DpExecutorResponse>,
    @Qualifier("reassignSender")
    private val reassignSender: BaseSyncSender<DpReassignRequest, DpBaseSyncResponse>,
    @Qualifier("notifySender")
    private val notifySender: BaseSyncSender<DpNotifyRequest, DpBaseSyncResponse>,
    @Qualifier("changeSlaSender")
    private val changeSlaSender: BaseSyncSender<DpChangeSlaRequest, DpBaseSyncResponse>,
    private val traceDao: TraceDao
) : DpSender {
    companion object {
        private const val PERFORMER_TASK_ID: String = "{performerTaskId}"
        private const val DIS_PRO_URL_PREFIX: String = "/disProLogic/api"
    }

    private val urlPrefix: String = "$DIS_PRO_URL_PREFIX/$svcVersion"

    override suspend fun requestExecutor(
        request: DpaRequestWrapper<DpaExecutorRequest>
    ): DpaSyncResponse = with(request) {
        executorRequestSender.send(
            this,
            originalRequest.dpRequest(operId),
            requestParams {
                headers(executorRequestHeaders(operId).asMap())
                uri("$urlPrefix/createPerformerTask")
            }
        ).dpaSyncResponse()
    }

    override suspend fun reassignExecutor(
        request: DpaRequestWrapper<DpaReassignRequest>
    ): DpaSyncResponse = reassignSender.sendAfterExecutorRequest(
        traceDao,
        request,
        DpaReassignRequest::dpRequest
    ) { operId, disResponseId ->
        requestParams {
            headers(reassignExecutorHeaders(operId).asMap())
            variable(PERFORMER_TASK_ID, disResponseId)
            uri("$urlPrefix/performerTask/$PERFORMER_TASK_ID/reassign")
        }
    }

    override suspend fun notify(
        request: DpaRequestWrapper<DpaNotifyRequest>
    ): DpaSyncResponse = notifySender.sendAfterExecutorRequest(
        traceDao,
        request,
        DpaNotifyRequest::dpRequest
    ) { operId, disResponseId ->
        requestParams {
            headers(notifyHeaders(operId).asMap())
            variable(PERFORMER_TASK_ID, disResponseId)
            uri("$urlPrefix/updatePerformerTask/$PERFORMER_TASK_ID/setStatus")
        }
    }

    override suspend fun changeSla(
        request: DpaRequestWrapper<DpaChangeSlaRequest>
    ): DpaSyncResponse = changeSlaSender.sendAfterExecutorRequest(
        traceDao,
        request,
        DpaChangeSlaRequest::dpRequest
    ) { operId, disResponseId ->
        requestParams {
            headers(changeSlaHeaders(operId).asMap())
            variable(PERFORMER_TASK_ID, disResponseId)
            uri("$urlPrefix/performerTask/$PERFORMER_TASK_ID/changeSla")
        }
    }
}package ru.sber.poirot.dpa.process.interaction

import org.springframework.stereotype.Service
import ru.sber.events.EventType.MESSAGE_RECEIVED
import ru.sber.poirot.dpa.common.IntegrationName
import ru.sber.poirot.dpa.common.IntegrationName.*
import ru.sber.poirot.dpa.common.event.EventMessageHandler
import ru.sber.poirot.dpa.interaction.DpSender
import ru.sber.poirot.dpa.interaction.sender.http.HttpDpSender
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.rqrs.*
import ru.sber.toJson

@Service
class ProcessDpSender(
    private val delegate: HttpDpSender,
    private val messageHandler: EventMessageHandler
) : DpSender {

    override suspend fun requestExecutor(request: DpaRequestWrapper<DpaExecutorRequest>): DpaSyncResponse =
        request.audit(EXECUTOR_REQUEST) { delegate.requestExecutor(request) }

    override suspend fun reassignExecutor(request: DpaRequestWrapper<DpaReassignRequest>): DpaSyncResponse =
        request.audit(REASSIGN) { delegate.reassignExecutor(request) }

    override suspend fun notify(request: DpaRequestWrapper<DpaNotifyRequest>): DpaSyncResponse =
        request.audit(NOTIFY) { delegate.notify(request) }

    override suspend fun changeSla(request: DpaRequestWrapper<DpaChangeSlaRequest>): DpaSyncResponse =
        request.audit(CHANGE_SLA) { delegate.changeSla(request) }

    private suspend fun <Resp> DpaRequestWrapper<*>.audit(
        integrationName: IntegrationName,
        action: suspend () -> Resp
    ): Resp = audit(
        operId,
        integrationName,
        processType,
        originalRequest.toJson(),
        action
    )

    private suspend fun <Resp> audit(
        rqUid: String,
        integrationName: IntegrationName,
        processType: ProcessType,
        content: String,
        action: suspend () -> Resp
    ): Resp {
        messageHandler.handle(
            rqUid,
            MESSAGE_RECEIVED,
            integrationName,
            processType,
            content = content
        )

        return action.invoke()
    }
}package ru.sber.poirot.dpa.process.interaction

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus.*
import ru.sber.poirot.dpa.model.rqrs.*
import ru.sber.poirot.dpa.model.rqrs.DpaRequestWrapper.Companion.wrap
import ru.sber.poirot.dpa.model.rqrs.DpaSyncResponse.Companion.DUMMY_SUCCESS_RESPONSE
import ru.sber.poirot.dpa.process.OperationInfoProvider.operationInfo
import ru.sber.poirot.dpa.trace.Trace
import ru.sber.poirot.dpa.trace.TraceDao
import ru.sber.poirot.dpa.trace.traceRecord
import ru.sber.utils.generateRqUId
import ru.sber.utils.logger

@Service
class ProcessRequestManager(
    private val sender: ProcessDpSender,
    private val traceDao: TraceDao
) {
    private val log = logger()

    companion object {
        private const val ABORTION_MESSAGE: String =
            "Interaction with DIS aborted: couldn't find any non-aborted trace" +
                    " taskId={}, processType={}, processTaskStatus={}"
    }

    suspend fun requestExecutor(request: DpaExecutorRequest): DpaSyncResponse =
        request.manageRq(
            WAITING_ASSIGNED_EXECUTOR,
            { operId: String? -> operId ?: generateRqUId() }
        ) { rq -> sender.requestExecutor(rq) }

    suspend fun reassignExecutor(request: DpaReassignRequest): DpaSyncResponse =
        request.manageRq(WAITING_REASSIGNED_EXECUTOR) { rq -> sender.reassignExecutor(rq) }

    suspend fun notify(request: DpaNotifyRequest): DpaSyncResponse = with(request) {
        manageRq(processTaskStatus) { rq -> sender.notify(rq) }
    }

    suspend fun changeSla(request: DpaChangeSlaRequest): DpaSyncResponse =
        request.manageRq(WAITING_CHANGED_SLA) { rq -> sender.changeSla(rq) }

    private suspend fun <T : DpaRequest> T.manageRq(
        status: ProcessTaskStatus,
        operIdFetcher: DpaRequest.(String?) -> String = { operId -> operIdOrException(operId) },
        action: suspend (DpaRequestWrapper<T>) -> DpaSyncResponse
    ): DpaSyncResponse = operInfo().let { (operId, abortInteraction) ->
        makeRq(operIdFetcher(operId), abortInteraction, status) { rq -> action(rq) }
    }

    private fun DpaRequest.operIdOrException(operId: String?): String =
        operId ?: throw IllegalStateException(
            "Should never happen: no operId for notify task=$taskId," +
                    " processType=$processType"
        )

    private suspend fun DpaRequest.operInfo(): Pair<String?, Boolean> =
        operationInfo().let { info -> info.operId to info.abortInteraction }

    private suspend fun <T : DpaRequest> T.makeRq(
        operId: String,
        abortInteraction: Boolean,
        status: ProcessTaskStatus,
        action: suspend (DpaRequestWrapper<T>) -> DpaSyncResponse
    ): DpaSyncResponse = when {
        abortInteraction -> spotWithAbortion(operId, processType, status)
        else -> action(wrap(operId, status))
    }

    private suspend fun DpaRequest.spotWithAbortion(
        operId: String,
        processType: ProcessType,
        processTaskStatus: ProcessTaskStatus,
    ): DpaSyncResponse {
        log.warn(ABORTION_MESSAGE, taskId, processType, processTaskStatus)

        trace(operId, processTaskStatus, true)
            .traceRecord()
            .also { traceDao.merge(it) }

        return DUMMY_SUCCESS_RESPONSE
    }

    private suspend fun trace(
        operId: String,
        processTaskStatus: ProcessTaskStatus,
        abortInteraction: Boolean
    ): Trace = traceDao.findByOperId(operId)!!.copy(
        processTaskStatus = processTaskStatus.name,
        abortInteraction = abortInteraction
    )
}package ru.sber.poirot.dpa.process.interaction

import jakarta.validation.Valid
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import ru.sber.poirot.dpa.model.rqrs.*

@RestController
@RequestMapping("/internal/process")
class PoirotProcessController(private val manager: ProcessRequestManager) {

    @PostMapping("/requestExecutor")
    suspend fun requestExecutor(@RequestBody request: DpaExecutorRequest): DpaSyncResponse =
        manager.requestExecutor(request)

    @PostMapping("/notify/**")
    suspend fun notify(@RequestBody request: DpaNotifyRequest): DpaSyncResponse =
        manager.notify(request)

    @PostMapping("/reassignExecutor")
    suspend fun reassignExecutor(
        @RequestBody
        @Valid
        request: DpaReassignRequest
    ): DpaSyncResponse = manager.reassignExecutor(request)

    @PostMapping("/changeSla")
    suspend fun changeSla(
        @RequestBody
        @Valid
        request: DpaChangeSlaRequest
    ): DpaSyncResponse = manager.changeSla(request)
}package ru.sber.poirot.dpa.client

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.DpaClientErrorCode.NO_RESPONSE_FROM_DPA
import ru.sber.poirot.dpa.client.DpaLogMessage.*
import ru.sber.poirot.dpa.model.rqrs.*
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.webclient.HttpException
import ru.sber.poirot.webclient.dsl.DslWebClient
import ru.sber.poirot.webclient.dsl.post
import ru.sber.utils.logger

@Service
class HttpDpaClient(private val dslDpaWebClient: DslWebClient) : DpaClient {
    companion object {
        private const val DPA_PREFIX: String = "/internal/process"
        private val log = logger()
    }

    override suspend fun requestExecutor(
        request: DpaExecutorRequest
    ): DpaSyncResponse = send(
        url = "$DPA_PREFIX/requestExecutor",
        request = request,
        logMessage = REQUEST_EXECUTOR
    )

    override suspend fun notify(
        request: DpaNotifyRequest
    ): DpaSyncResponse = with(request) {
        send(
            url = "$DPA_PREFIX/notify",
            request = request,
            logMessage = NOTIFY,
            taskId,
            processTaskStatus,
            processType
        )
    }

    override suspend fun reassignExecutor(
        request: DpaReassignRequest
    ): DpaSyncResponse = send(
        url = "$DPA_PREFIX/reassignExecutor",
        request = request,
        logMessage = REASSIGN_EXECUTOR
    )

    override suspend fun changeSla(
        request: DpaChangeSlaRequest
    ): DpaSyncResponse = send(
        url = "$DPA_PREFIX/changeSla",
        request = request,
        logMessage = CHANGE_SLA
    )

    private suspend fun send(
        url: String,
        request: DpaRequest,
        logMessage: DpaLogMessage,
        vararg args: Any
    ): DpaSyncResponse = actWithExceptionPropagation {
        with(request) {
            val argss = when {
                args.isEmpty() -> arrayOf(taskId, processType)
                else -> args
            }

            log.info(logMessage.message, argss)

            dslDpaWebClient.post<DpaSyncResponse> {
                path = url
                body = request
            }
        }
    }

    private suspend fun actWithExceptionPropagation(action: suspend () -> DpaSyncResponse?): DpaSyncResponse =
        try {
            action.invoke() ?: throw FrontException(NO_RESPONSE_FROM_DPA)
        } catch (e: HttpException) {
            throw FrontException(e.message)
        }
}package ru.sber.poirot.dpa.model.rqrs

import jakarta.validation.constraints.Size
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.common.ChangeSlaEmployee
import ru.sber.poirot.dpa.model.common.ChangeSlaInfo

class DpaChangeSlaRequest(
    override val taskId: String,
    override val processType: ProcessType,
    val initiator: ChangeSlaEmployee,
    val changeInfo: ChangeSlaInfo? = null,
    @field:Size(max = 255, message = "Причина превышает допустимый лимит: 255 символов")
    val reason: String,
    @field:Size(max = 2048, message = "Комментарий превышает допустимый лимит: 2048 символов")
    val comment: String? = null,
) : DpaRequest package ru.sber.poirot.dpa.interaction.sender.model

import ru.sber.poirot.dpa.interaction.listener.dictionaries.DpAction.Companion.dpAction
import ru.sber.poirot.dpa.interaction.listener.dictionaries.DpEventType.Companion.eventType
import ru.sber.poirot.dpa.interaction.sender.model.DpNotifyEventType.Companion.dpNotifyEventType
import ru.sber.poirot.dpa.model.common.*
import ru.sber.poirot.dpa.model.rqrs.DpaChangeSlaRequest
import ru.sber.poirot.dpa.model.rqrs.DpaExecutorRequest
import ru.sber.poirot.dpa.model.rqrs.DpaNotifyRequest
import ru.sber.poirot.dpa.model.rqrs.DpaReassignRequest

fun DpaExecutorRequest.dpRequest(operId: String): DpExecutorRequest = DpExecutorRequest(
    keyBusinessObject = BusinessObject(customerId),
    creationEvent = CreationEvent(),
    creditBusinessProcess = creditBusinessProcess,
    initiator = initiator,
    performerContainer = PerformerContainer(performerCategory.category),
    taskSource = TaskSource(workId = operId, externalId = taskSourceExternalId ?: operId),
    taskIdentification = taskIdentification,
    taskCost = TaskCost(profitOwner)
)

fun DpaReassignRequest.dpRequest(operId: String): DpReassignRequest = DpReassignRequest(
    event = ReassignmentEvent(
        type = mode.eventType(),
        initiator = DpReassignEmployee(
            idInfos = initiator.idInfos,
            fullName = initiator.fullName
        )
    ),
    params = ReassignmentParams(
        reason = reason,
        comment = comment,
        targetPerformer = targetExecutor?.let {
            DpReassignEmployee(
                idInfos = it.idInfos,
                fullName = it.fullName
            )
        },
    )
)

fun DpaNotifyRequest.dpRequest(operId: String): DpNotifyRequest = DpNotifyRequest(
    workId = operId,
    processTaskStatus = processTaskStatus,
    statusEvent = NotifyStatusEvent(
        action = processTaskStatus.dpAction(),
        type = processTaskStatus.dpNotifyEventType(),
        initiator = initiator
    ),
    changeStatusReason = changeStatusReason,
    requestDecisions = requestDecisions,
)

fun DpaChangeSlaRequest.dpRequest(operId: String): DpChangeSlaRequest = DpChangeSlaRequest(
    workId = operId,
    changeReason = reason,
    changeEvent = ChangeSlaEvent(
        initiator = initiator,
        changeInfo = changeInfo
    ),
    comment = comment
) в итоге в сам дис отправляется этот процес тайп из бина
