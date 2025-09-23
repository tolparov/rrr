package ru.sber.poirot.dpa.request.impl

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.client.DpaClient
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.common.ChangeSlaEmployee
import ru.sber.poirot.dpa.model.common.ChangeSlaInfo
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus
import ru.sber.poirot.dpa.model.dictionaries.ReassignMode
import ru.sber.poirot.dpa.model.rqrs.DpaSyncResponse
import ru.sber.poirot.dpa.model.rqrs.DpaSyncResponse.Companion.PARALLEL_RUN_EMPTY_RESPONSE
import ru.sber.poirot.dpa.request.DpaRequestManager
import ru.sber.poirot.dpa.request.baseEmployee
import java.time.LocalDateTime

@Service
class DefaultDpaRequestManager<T : Any>(
    private val dpaClient: DpaClient,
    private val factory: DpaRequestFactory<T>,
    private val processType: ProcessType,
) : DpaRequestManager<T> {

    override suspend fun requestExecutor(
        task: T,
        onFail: suspend (DpaSyncResponse) -> Unit,
    ): DpaSyncResponse = sendRequest(onFail) {
        dpaClient.requestExecutor(factory.executorRequest(task))
    }

    override suspend fun notify(
        status: ProcessTaskStatus,
        task: T,
        onFail: suspend (DpaSyncResponse) -> Unit,
    ): DpaSyncResponse = sendRequest(onFail) {
        dpaClient.notify(factory.notifyRequest(TaskNotifyWrapper(task, status)))
    }

    override suspend fun reassignExecutor(
        task: T,
        mode: ReassignMode,
        initiator: String,
        reason: String,
        targetExecutor: String?,
        comment: String?,
        onFail: suspend (DpaSyncResponse) -> Unit,
    ): DpaSyncResponse = sendRequest(onFail) {
        dpaClient.reassignExecutor(
            factory.reassignRequest(
                TaskReassignWrapper(
                    task = task,
                    mode = mode,
                    initiator = baseEmployee(initiator),
                    reason = reason,
                    targetExecutor = targetExecutor?.let { baseEmployee(it) },
                    comment = comment,
                )
            )
        )
    }

    override suspend fun changeSla(
        taskId: String,
        initiator: String,
        reason: String,
        absoluteDeadline: LocalDateTime?,
        absoluteGoal: LocalDateTime?,
        comment: String?,
        onFail: suspend (DpaSyncResponse) -> Unit,
    ): DpaSyncResponse = sendRequest(onFail) {
        dpaClient.changeSla(
            factory.changeSlaRequest(
                TaskChangeSlaWrapper(
                    taskId = taskId,
                    processType = processType,
                    initiator = ChangeSlaEmployee(initiator),
                    changeSlaInfo = when {
                        listOfNotNull(absoluteDeadline, absoluteGoal).isEmpty() -> null
                        else -> ChangeSlaInfo(absoluteDeadline, absoluteGoal)
                    },
                    reason = reason,
                )
            )
        )
    }

    private suspend fun sendRequest(
        onFail: suspend (DpaSyncResponse) -> Unit,
        sender: suspend () -> DpaSyncResponse,
    ): DpaSyncResponse = runCatching {
        sender.invoke().also { response ->
            if (!response.success) {
                onFail.invoke(response)
            }
        }
    }.onFailure { onFail.invoke(PARALLEL_RUN_EMPTY_RESPONSE) }.getOrThrow()
}package ru.sber.poirot.dpa.request.impl

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.rqrs.DpaChangeSlaRequest
import ru.sber.poirot.dpa.model.rqrs.DpaExecutorRequest
import ru.sber.poirot.dpa.model.rqrs.DpaNotifyRequest
import ru.sber.poirot.dpa.model.rqrs.DpaReassignRequest
import ru.sber.poirot.dpa.request.DpaRequestBuilder

@Service
class DpaRequestFactory<T : Any>(
    private val executorRequestBuilder: DpaRequestBuilder<T, DpaExecutorRequest>,
    private val notifyRequestBuilder: DpaRequestBuilder<TaskNotifyWrapper<T>, DpaNotifyRequest>,
    private val reassignRequestBuilder: DpaRequestBuilder<TaskReassignWrapper<T>, DpaReassignRequest>,
    private val changeSlaRequestBuilder: DpaChangeSlaRequestBuilder,
    private val clientInfoProvider: DpaCreditClientProvider
) {

    suspend fun executorRequest(task: T): DpaExecutorRequest =
        executorRequestBuilder.build(task, clientInfoProvider)

    suspend fun notifyRequest(task: TaskNotifyWrapper<T>): DpaNotifyRequest =
        notifyRequestBuilder.build(task, clientInfoProvider)

    suspend fun reassignRequest(task: TaskReassignWrapper<T>): DpaReassignRequest =
        reassignRequestBuilder.build(task, clientInfoProvider)

    suspend fun changeSlaRequest(task: TaskChangeSlaWrapper): DpaChangeSlaRequest =
        changeSlaRequestBuilder.build(task, clientInfoProvider)
}package ru.sber.poirot.dpa.request.impl

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.rqrs.DpaChangeSlaRequest
import ru.sber.poirot.dpa.request.DpaRequestBuilder

@Component
class DpaChangeSlaRequestBuilder : DpaRequestBuilder<TaskChangeSlaWrapper, DpaChangeSlaRequest> {

    override suspend fun build(
        task: TaskChangeSlaWrapper,
        creditClientProvider: DpaCreditClientProvider
    ): DpaChangeSlaRequest = with(task) {
        DpaChangeSlaRequest(
            taskId = taskId,
            processType = processType,
            initiator = initiator,
            changeInfo = changeSlaInfo,
            reason = reason,
            comment = comment
        )
    }
}package ru.sber.poirot.dpa.request.impl

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.rqrs.DpaChangeSlaRequest
import ru.sber.poirot.dpa.model.rqrs.DpaExecutorRequest
import ru.sber.poirot.dpa.model.rqrs.DpaNotifyRequest
import ru.sber.poirot.dpa.model.rqrs.DpaReassignRequest
import ru.sber.poirot.dpa.request.DpaRequestBuilder

@Service
class DpaRequestFactory<T : Any>(
    private val executorRequestBuilder: DpaRequestBuilder<T, DpaExecutorRequest>,
    private val notifyRequestBuilder: DpaRequestBuilder<TaskNotifyWrapper<T>, DpaNotifyRequest>,
    private val reassignRequestBuilder: DpaRequestBuilder<TaskReassignWrapper<T>, DpaReassignRequest>,
    private val changeSlaRequestBuilder: DpaChangeSlaRequestBuilder,
    private val clientInfoProvider: DpaCreditClientProvider
) {

    suspend fun executorRequest(task: T): DpaExecutorRequest =
        executorRequestBuilder.build(task, clientInfoProvider)

    suspend fun notifyRequest(task: TaskNotifyWrapper<T>): DpaNotifyRequest =
        notifyRequestBuilder.build(task, clientInfoProvider)

    suspend fun reassignRequest(task: TaskReassignWrapper<T>): DpaReassignRequest =
        reassignRequestBuilder.build(task, clientInfoProvider)

    suspend fun changeSlaRequest(task: TaskChangeSlaWrapper): DpaChangeSlaRequest =
        changeSlaRequestBuilder.build(task, clientInfoProvider)
} я хочу понять на что вообще влияет передаваемый processType через бин
