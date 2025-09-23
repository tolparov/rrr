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
} 
Description:

Parameter 2 of constructor in ru.sber.poirot.dpa.request.impl.DefaultDpaRequestManager required a bean of type 'ru.sber.poirot.dpa.model.ProcessType' that could not be found.


Action:

Consider defining a bean of type 'ru.sber.poirot.dpa.model.ProcessType' in your configuration.


Process finished with exit code 1
