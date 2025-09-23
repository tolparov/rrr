interface FmDpaStrategy {
    suspend fun buildExecutorRequest(task: FmRecord, clientProvider: DpaCreditClientProvider): DpaExecutorRequest
    suspend fun buildNotifyRequest(task: TaskNotifyWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaNotifyRequest
    suspend fun buildReassignRequest(task: TaskReassignWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaReassignRequest
}

@Component
class FocusMonitoringStrategy : FmDpaStrategy {
    override suspend fun buildExecutorRequest(task: FmRecord, clientProvider: DpaCreditClientProvider): DpaExecutorRequest {
        // вся старая логика тут
    }

    override suspend fun buildNotifyRequest(task: TaskNotifyWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaNotifyRequest {
        // старая логика
    }

    override suspend fun buildReassignRequest(task: TaskReassignWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaReassignRequest {
        // старая логика
    }
}

@Component
class MonitoringKsbStrategy : FmDpaStrategy {
    override suspend fun buildExecutorRequest(task: FmRecord, clientProvider: DpaCreditClientProvider): DpaExecutorRequest {
        // новая логика
    }

    override suspend fun buildNotifyRequest(task: TaskNotifyWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaNotifyRequest {
        // новая логика
    }

    override suspend fun buildReassignRequest(task: TaskReassignWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaReassignRequest {
        // новая логика
    }
}
@Component
class FmDpaStrategyFactory(
    private val strategies: List<FmDpaStrategy>
) {
    fun forProcessType(processType: ProcessType): FmDpaStrategy =
        strategies.find {
            when (processType) {
                ProcessType.FOCUS_MONITORING -> it is FocusMonitoringStrategy
                ProcessType.MONITORING_KSB -> it is MonitoringKsbStrategy
                else -> false
            }
        } ?: throw IllegalArgumentException("No strategy for $processType")
}
package ru.sber.poirot.focus.shared.dpa.strategy

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.PRODUCT_PR_125
import ru.sber.poirot.dpa.model.common.*
import ru.sber.poirot.dpa.model.common.DoneDecisionReason.RD_01001
import ru.sber.poirot.dpa.model.common.DoneRequestDecision.Companion.doneRequestDecision
import ru.sber.poirot.dpa.model.common.DoneRequestDecision.DC_NOT
import ru.sber.poirot.dpa.model.dictionaries.BusinessLine.KA
import ru.sber.poirot.dpa.model.dictionaries.BusinessProcess.BC_FMO
import ru.sber.poirot.dpa.model.dictionaries.PerformerCategory.FOURTH
import ru.sber.poirot.dpa.model.dictionaries.ProfitOwner.CS_DRKIB
import ru.sber.poirot.dpa.model.dictionaries.RequestCategory.RQ_168
import ru.sber.poirot.dpa.model.dictionaries.RequestType.TP_072
import ru.sber.poirot.dpa.model.dictionaries.RequestType.TP_073
import ru.sber.poirot.dpa.model.dictionaries.ChangeStatusReason.Companion.changeStatusReason
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus.DONE
import ru.sber.poirot.dpa.model.rqrs.*
import ru.sber.poirot.dpa.request.*
import ru.sber.poirot.dpa.request.impl.TaskNotifyWrapper
import ru.sber.poirot.dpa.request.impl.TaskReassignWrapper
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource.AUTO
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource.Companion.findById
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.userinfoprovider.UserInfoProvider

@Component
class FocusMonitoringStrategy(
    private val userInfoProvider: UserInfoProvider
) : FmDpaStrategy {

    override suspend fun buildExecutorRequest(
        task: FmRecord,
        clientProvider: DpaCreditClientProvider
    ): DpaExecutorRequest {
        val client = clientProvider.creditBusinessProcessClient(task)

        return DpaExecutorRequest(
            taskId = task.id,
            processType = task.processTypeEnum(),
            customerId = client.customerId,
            initiator = when {
                task.initiator == "AUTO" -> autoExecutorRequestInitiator()
                else -> executorRequestInitiator(task.initiator!!) { login ->
                    userInfoProvider.getFioByUsername(login)
                }
            },
            creditBusinessProcess = CreditBusinessProcess(product = PRODUCT_PR_125, client = client),
            taskIdentification = TaskIdentification(
                businessProcess = BC_FMO,
                businessLine = KA,
                requestType = when (findById(task.inputSource)) {
                    AUTO -> TP_072
                    else -> TP_073
                },
                requestCategory = RQ_168,
            ),
            profitOwner = CS_DRKIB,
            performerCategory = FOURTH
        )
    }

    override suspend fun buildNotifyRequest(
        wrapper: TaskNotifyWrapper<FmRecord>,
        clientProvider: DpaCreditClientProvider
    ): DpaNotifyRequest {
        val (task, status) = wrapper
        val client = clientProvider.creditBusinessProcessClient(task)
        val decision = doneRequestDecision(status, task.confirmedFraud?.let { !it } ?: false)

        return DpaNotifyRequest(
            taskId = task.id,
            processType = task.processTypeEnum(),
            initiator = initiator(task),
            processTaskStatus = status,
            requestDecisions = RequestDecisions(
                decision = decision,
                decisionReasons = doneDecisionReasonContainers(status, decision),
                decisionObject = DecisionObject(objectId = client.customerId)
            ),
            changeStatusReason = changeStatusReason(status, task.executor)
        )
    }

    override suspend fun buildReassignRequest(
        wrapper: TaskReassignWrapper<FmRecord>,
        clientProvider: DpaCreditClientProvider
    ): DpaReassignRequest {
        val task = wrapper.task
        val grantedStatuses: List<MonitoringStatus> =
            listOf(
                MonitoringStatus.EXECUTOR_ASSIGNED,
                MonitoringStatus.IN_WORK,
                MonitoringStatus.SLA_PROLONGATION_CONFIRMATION,
                MonitoringStatus.SLA_PROLONGATION_REQUEST
            )

        if (task.statusId !in grantedStatuses.map { it.id }) {
            throw IllegalArgumentException(
                "Reassign not allowed. Current status=${task.statusId}, allowed=${grantedStatuses.map { it.status }}"
            )
        }

        return DpaReassignRequest(
            taskId = task.id,
            processType = task.processTypeEnum(),
            mode = wrapper.mode,
            initiator = wrapper.initiator,
            reason = wrapper.reason,
            comment = wrapper.comment,
            targetExecutor = wrapper.targetExecutor
        )
    }

    private fun initiator(task: FmRecord): BaseEmployee = with(task) {
        when {
            executor != null -> userEmployeeWithEmail(executor)
            initiator != "AUTO" && initiator != null -> userEmployeeWithEmail(initiator)
            else -> autoEmployee()
        }
    }

    private fun doneDecisionReasonContainers(
        status: ProcessTaskStatus,
        decision: DoneRequestDecision?
    ): List<DoneDecisionReasonContainer> = when {
        status == DONE && decision == DC_NOT -> listOf(DoneDecisionReasonContainer(RD_01001))
        else -> emptyList()
    }
}
