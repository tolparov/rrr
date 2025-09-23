package ru.sber.poirot.dpa.request

import ru.sber.poirot.dpa.model.rqrs.DpaRequest
import ru.sber.poirot.dpa.credit.DpaCreditClientProvider

fun interface DpaRequestBuilder<T : Any, DpaReq : DpaRequest> {

    suspend fun build(task: T, creditClientProvider: DpaCreditClientProvider): DpaReq
}
package ru.sber.poirot.dpa.request.impl

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
}
