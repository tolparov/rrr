@Component
class MonitoringProcessStrategyFactory(
    private val focusMonitoringStrategy: FocusMonitoringStrategy,
    private val monitoringKsbStrategy: MonitoringKsbStrategy
) {

    fun forProcessType(processType: ProcessType): FmDpaStrategy = when (processType) {
        ProcessType.FOCUS_MONITORING -> focusMonitoringStrategy
        ProcessType.MONITORING_KSB -> monitoringKsbStrategy
    }
}
@Component
class FmDpaExecutorRequestBuilder(
    private val strategyFactory: MonitoringProcessStrategyFactory,
    private val clientProvider: DpaCreditClientProvider
) {

    suspend fun build(task: FmRecord): DpaExecutorRequest {
        val strategy = strategyFactory.forProcessType(task.processTypeEnum())
        return strategy.buildExecutorRequest(task, clientProvider)
    }

    suspend fun buildNotify(task: TaskNotifyWrapper<FmRecord>): DpaNotifyRequest {
        val strategy = strategyFactory.forProcessType(task.task.processTypeEnum())
        return strategy.buildNotifyRequest(task, clientProvider)
    }

    suspend fun buildReassign(task: TaskReassignWrapper<FmRecord>): DpaReassignRequest {
        val strategy = strategyFactory.forProcessType(task.task.processTypeEnum())
        return strategy.buildReassignRequest(task, clientProvider)
    }
}
