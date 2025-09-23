package ru.sber.poirot.focus.shared.dpa.listen

import org.springframework.stereotype.Service
import ru.sber.poirot.dpa.listen.DpaAssigner
import ru.sber.poirot.dpa.listen.DpaProcessTaskFetcher
import ru.sber.poirot.dpa.model.common.AssignedExecutor
import ru.sber.poirot.dpa.model.dictionaries.ProcessEventErrorCode.CANT_ASSIGN
import ru.sber.poirot.dpa.model.rqrs.DpaProcessEventResponse
import ru.sber.poirot.dpa.model.rqrs.DpaProcessEventResponse.Companion.PositiveDpaProcessEventResponse
import ru.sber.poirot.dpa.model.rqrs.DpaProcessEventResponse.Companion.errorProcessEventResponse
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.*
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.Companion.getStatusById
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.shared.records.model.FmRecord

@Service
class FmDpaAssigner(
    override val taskFetcher: DpaProcessTaskFetcher<FmRecord>,
    private val focusDao: FmRecordDao,
) : DpaAssigner<FmRecord> {
    override val grantedStatuses: List<MonitoringStatus> =
        listOf(
            DIS_REQUEST,
            DIS_REASSIGNMENT,
            EXECUTOR_ASSIGNED,
            IN_WORK,
            SLA_PROLONGATION_CONFIRMATION,
            SLA_PROLONGATION_REQUEST,
        )

    override suspend fun assign(
        taskId: String,
        executor: AssignedExecutor,
        task: FmRecord?,
    ): DpaProcessEventResponse = (task ?: taskFetcher.fetchExceptionally(taskId))
        .let {
            if (it.statusId !in grantedStatuses.map { s -> s.id }) {
                return@let errorProcessEventResponse(
                    CANT_ASSIGN,
                    "Текущий статус=${getStatusById(it.statusId)?.status}"
                )
            }

            focusDao.merge(
                it.copy(statusId = EXECUTOR_ASSIGNED.id, executor = executor.login).toFocusMonitoringRecord()
            )

            PositiveDpaProcessEventResponse
        }
}
package ru.sber.poirot.focus.shared.dpa.listen

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import ru.sber.poirot.dpa.listen.DpaProcessTaskFetcher
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.ProcessType.FOCUS_MONITORING
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.Companion.getStatusById
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.utils.logger

@Configuration
class FmDpaProcessConfig(private val fmDao: FmRecordDao) {
    private val log = logger()

    @Bean
    fun fmTaskFetcher(): DpaProcessTaskFetcher<FmRecord> =
        DpaProcessTaskFetcher { taskId ->
            fmDao.findRecordBy(taskId.toLong())
                ?.also {
                    log.info(
                        "Fetched focus monitoring taskId={}, status={}",
                        taskId,
                        getStatusById(it.statusId)?.status
                    )
                }
        }
}package ru.sber.poirot.focus.shared.dpa.request

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.PRODUCT_PR_125
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.common.CreditBusinessProcess
import ru.sber.poirot.dpa.model.common.TaskIdentification
import ru.sber.poirot.dpa.model.dictionaries.BusinessLine.KA
import ru.sber.poirot.dpa.model.dictionaries.BusinessProcess.BC_FMO
import ru.sber.poirot.dpa.model.dictionaries.PerformerCategory.FOURTH
import ru.sber.poirot.dpa.model.dictionaries.ProfitOwner.CS_DRKIB
import ru.sber.poirot.dpa.model.dictionaries.RequestCategory.RQ_168
import ru.sber.poirot.dpa.model.dictionaries.RequestType.TP_072
import ru.sber.poirot.dpa.model.dictionaries.RequestType.TP_073
import ru.sber.poirot.dpa.model.rqrs.DpaExecutorRequest
import ru.sber.poirot.dpa.request.DpaRequestBuilder
import ru.sber.poirot.dpa.request.autoExecutorRequestInitiator
import ru.sber.poirot.dpa.request.executorRequestInitiator
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource.AUTO
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource.Companion.findById
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.userinfoprovider.UserInfoProvider

@Component
class FmDpaExecutorRequestBuilder(
    private val processType: ProcessType,
    private val userInfoProvider: UserInfoProvider
) : DpaRequestBuilder<FmRecord, DpaExecutorRequest> {
    override suspend fun build(
        task: FmRecord,
        creditClientProvider: DpaCreditClientProvider
    ): DpaExecutorRequest {
        val client = creditClientProvider.creditBusinessProcessClient(task)

        return DpaExecutorRequest(
            taskId = task.id,
            processType = processType,
            customerId = client.customerId,
            initiator = when {
                task.initiator == "AUTO" -> autoExecutorRequestInitiator()
                else -> executorRequestInitiator(task.initiator!!) { login ->
                    userInfoProvider.getFioByUsername(login)
                }
            },
            creditBusinessProcess = CreditBusinessProcess(product = PRODUCT_PR_125, client = client),
            taskIdentification = taskIdentification(task),
            profitOwner = CS_DRKIB,
            performerCategory = FOURTH
        )
    }

    private fun taskIdentification(record: FmRecord): TaskIdentification = TaskIdentification(
        businessProcess = BC_FMO,
        businessLine = KA,
        requestType = when (findById(record.inputSource)) {
            AUTO -> TP_072
            else -> TP_073
        },
        requestCategory = RQ_168,
    )
}package ru.sber.poirot.focus.shared.dpa.strategy

import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.dpa.model.rqrs.DpaExecutorRequest
import ru.sber.poirot.dpa.model.rqrs.DpaNotifyRequest
import ru.sber.poirot.dpa.model.rqrs.DpaReassignRequest
import ru.sber.poirot.dpa.request.impl.TaskNotifyWrapper
import ru.sber.poirot.dpa.request.impl.TaskReassignWrapper

/**
 * Интерфейс для стратегии билда DPA-запросов
 */
interface FmDpaStrategy {
    suspend fun buildExecutorRequest(task: FmRecord, clientProvider: DpaCreditClientProvider): DpaExecutorRequest
    suspend fun buildNotifyRequest(task: TaskNotifyWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaNotifyRequest
    suspend fun buildReassignRequest(task: TaskReassignWrapper<FmRecord>, clientProvider: DpaCreditClientProvider): DpaReassignRequest
}package ru.sber.poirot.focus.shared.dpa.strategy

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
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.*
import ru.sber.poirot.focus.shared.dpa.request.creditBusinessProcessClient
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
                EXECUTOR_ASSIGNED,
                IN_WORK,
                SLA_PROLONGATION_CONFIRMATION,
                SLA_PROLONGATION_REQUEST
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
}package ru.sber.poirot.focus.shared.dpa.strategy

import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.ProcessType.FOCUS_MONITORING
import ru.sber.poirot.dpa.model.ProcessType.MONITORING_KSB
import ru.sber.poirot.focus.shared.records.model.FmRecord

fun FmRecord.processTypeEnum(): ProcessType = if (processType == 11) MONITORING_KSB else FOCUS_MONITORINGpackage ru.sber.poirot.focus.shared.dpa.strategy

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.rqrs.DpaExecutorRequest
import ru.sber.poirot.dpa.model.rqrs.DpaNotifyRequest
import ru.sber.poirot.dpa.model.rqrs.DpaReassignRequest
import ru.sber.poirot.dpa.request.impl.TaskNotifyWrapper
import ru.sber.poirot.dpa.request.impl.TaskReassignWrapper
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.userinfoprovider.UserInfoProvider

@Component
class MonitoringKsbStrategy(
    private val userInfoProvider: UserInfoProvider
) : FmDpaStrategy {
    override suspend fun buildExecutorRequest(
        task: FmRecord,
        clientProvider: DpaCreditClientProvider
    ): DpaExecutorRequest {
        TODO("Not yet implemented")
    }

    override suspend fun buildNotifyRequest(
        task: TaskNotifyWrapper<FmRecord>,
        clientProvider: DpaCreditClientProvider
    ): DpaNotifyRequest {
        TODO("Not yet implemented")
    }

    override suspend fun buildReassignRequest(
        task: TaskReassignWrapper<FmRecord>,
        clientProvider: DpaCreditClientProvider
    ): DpaReassignRequest {
        TODO("Not yet implemented")
    }

}
