package ru.sber.poirot.dpa.process.interaction

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
}
