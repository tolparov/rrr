package ru.sber.poirot.focus.shared.infra.dis.reassignment

import org.springframework.stereotype.Service
import ru.sber.permissions.focus.BasketPermissions.STATUS_EXECUTOR_ASSIGNED_FM
import ru.sber.permissions.focus.BasketPermissions.STATUS_IN_WORK_FM
import ru.sber.permissions.focus.RegistryPermissions.FM_REASSIGNMENT
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.process.ProcessDelegate
import ru.sber.poirot.dpa.reassignment.impl.ProcessReassignment
import ru.sber.poirot.dpa.request.ParallelRunProcessDisRequestManager
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.EXECUTOR_ASSIGNED
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.IN_WORK
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.userinfoprovider.UserInfoProviderFactory

@Service
class ProcessReassignmentImpl(
    userInfoProviderFactory: UserInfoProviderFactory,
    override val processType: ProcessType,
    override val processDelegate: ProcessDelegate<FmRecord, MonitoringStatus>,
    override val disRequestManager: ParallelRunProcessDisRequestManager<FmRecord>,
) : ProcessReassignment<FmRecord, MonitoringStatus>(
    initiatorPermission = FM_REASSIGNMENT,
    executorPermissions = arrayOf(STATUS_EXECUTOR_ASSIGNED_FM, STATUS_IN_WORK_FM),
    availableStatuses = listOf(EXECUTOR_ASSIGNED, IN_WORK),
    userInfoProviderFactory = userInfoProviderFactory,
)package ru.sber.poirot.focus.shared.infra.dis.reassignment

import org.springframework.stereotype.Service
import ru.sber.poirot.dis.adapter.client.AS_DIS_LOGIN
import ru.sber.poirot.dis.adapter.client.handlers.reassignment.ReassignmentService
import ru.sber.poirot.dis.adapter.client.handlers.reassignment.ReassignmentStatus.*
import ru.sber.poirot.dis.adapter.client.handlers.requests.ReassignmentRequest
import ru.sber.poirot.dis.adapter.client.model.StatusHolder
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.*
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.Companion.ids
import ru.sber.poirot.focus.shared.infra.dis.DisAdapterConfig.Companion.getId
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao

@Service
class ReassignmentServiceImpl(private val focusDao: FmRecordDao) : ReassignmentService {
    private val statuses = listOf(
        EXECUTOR_ASSIGNED,
        IN_WORK,
        SLA_PROLONGATION_CONFIRMATION,
        SLA_PROLONGATION_REQUEST
    )

    override suspend fun reassign(request: ReassignmentRequest): StatusHolder {
        val recordId = getId(request.taskId)

        val record = focusDao.findRecordBy(recordId) ?: return INCORRECT_RECORD_ID.statusHolder
        if (record.statusId !in statuses.ids) return INCORRECT_STATUS.statusHolder

        focusDao.merge(
            record.copy(statusId = DIS_REASSIGNMENT.id, executor = AS_DIS_LOGIN)
                .toFocusMonitoringRecord()
        )

        return TASK_IN_REASSIGNMENT_STAGE.statusHolder
    }
}package ru.sber.poirot.focus.shared.infra.dis.sla

import org.springframework.stereotype.Service
import ru.sber.permissions.focus.RegistryPermissions.FM_SLA_PROLONGATION
import ru.sber.permissions.focus.RegistryPermissions.FM_SLA_PROLONGATION_CONFIRMATION
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.process.ProcessDelegate
import ru.sber.poirot.dpa.request.ParallelRunProcessDisRequestManager
import ru.sber.poirot.dpa.sla.prolongation.impl.ProcessSlaProlongation
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.IN_WORK
import ru.sber.poirot.focus.shared.records.model.FmRecord

@Service
class ProcessSlaProlongationImpl(
    override val processType: ProcessType,
    override val processDelegate: ProcessDelegate<FmRecord, MonitoringStatus>,
    override val disRequestManager: ParallelRunProcessDisRequestManager<FmRecord>,
) : ProcessSlaProlongation<FmRecord, MonitoringStatus>(
    initiatorPermission = FM_SLA_PROLONGATION,
    confirmationPermission = FM_SLA_PROLONGATION_CONFIRMATION,
    availableStatuses = listOf(IN_WORK),
) видимо тут тожн из бина processType берутся данные 
