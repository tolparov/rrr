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
}package ru.sber.poirot.focus.shared.dpa.listen

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

    @Bean
    fun processType(): ProcessType = FOCUS_MONITORING
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
}package ru.sber.poirot.focus.shared.dpa.request

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.common.*
import ru.sber.poirot.dpa.model.common.DoneDecisionReason.RD_01001
import ru.sber.poirot.dpa.model.common.DoneRequestDecision.Companion.doneRequestDecision
import ru.sber.poirot.dpa.model.common.DoneRequestDecision.DC_NOT
import ru.sber.poirot.dpa.model.dictionaries.ChangeStatusReason.Companion.changeStatusReason
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus
import ru.sber.poirot.dpa.model.dictionaries.ProcessTaskStatus.DONE
import ru.sber.poirot.dpa.model.rqrs.DpaNotifyRequest
import ru.sber.poirot.dpa.request.DpaRequestBuilder
import ru.sber.poirot.dpa.request.autoEmployee
import ru.sber.poirot.dpa.request.impl.TaskNotifyWrapper
import ru.sber.poirot.dpa.request.userEmployeeWithEmail
import ru.sber.poirot.focus.shared.records.model.FmRecord

@Component
class FmDpaNotifyRequestBuilder(
    private val processType: ProcessType
) : DpaRequestBuilder<TaskNotifyWrapper<FmRecord>, DpaNotifyRequest> {

    override suspend fun build(
        wrapper: TaskNotifyWrapper<FmRecord>,
        creditClientProvider: DpaCreditClientProvider
    ): DpaNotifyRequest {
        val (task, status) = wrapper
        val client = creditClientProvider.creditBusinessProcessClient(task)
        val decision = doneRequestDecision(status, task.confirmedFraud?.let { !it } ?: false)

        return DpaNotifyRequest(
            taskId = task.id,
            processType = processType,
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
}package ru.sber.poirot.focus.shared.dpa.request

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.DpaClientErrorCode.CANT_REASSIGN_EXECUTOR_WRONG_STATUS
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.rqrs.DpaReassignRequest
import ru.sber.poirot.dpa.request.DpaRequestBuilder
import ru.sber.poirot.dpa.request.impl.TaskReassignWrapper
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.*
import ru.sber.poirot.focus.shared.records.model.FmRecord

@Component
class FmDpaReassignRequestBuilder(
    private val processType: ProcessType,
) : DpaRequestBuilder<TaskReassignWrapper<FmRecord>, DpaReassignRequest> {
    private val grantedStatuses: List<MonitoringStatus> =
        listOf(EXECUTOR_ASSIGNED, IN_WORK, SLA_PROLONGATION_CONFIRMATION, SLA_PROLONGATION_REQUEST)

    override suspend fun build(
        wrapper: TaskReassignWrapper<FmRecord>,
        creditClientProvider: DpaCreditClientProvider
    ): DpaReassignRequest = with(wrapper) {
        if (task.statusId !in grantedStatuses.map { it.id }) {
            throw FrontException(
                CANT_REASSIGN_EXECUTOR_WRONG_STATUS,
                grantedStatuses.map { it.status }.joinToString { ", " }
            )
        }

        DpaReassignRequest(
            taskId = task.id,
            processType = processType,
            mode = mode,
            initiator = initiator,
            reason = reason,
            comment = comment,
            targetExecutor = targetExecutor
        )
    }
} вообщем это так выглядит текущая интеграция с ДИС но появился новый процесс type MONITORING_KSB и нужно чтоб в этом же сервисе он отправлялся по отдельной бизнес линии как отдельный процесс и билдиться запросы будут с другими параметрами все это будет зависить от processType самой задачи если он 11 то используем одни запросы которые представленны если 11 то новые я их сам заполню
