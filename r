package ru.sber.poirot.focus.shared.dpa.strategy

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.focus.shared.records.model.FmRecord

/**
 * Интерфейс для стратегии билда DPA-запросов
 */
interface MonitoringProcessStrategy {
    fun processType(): ProcessType

    fun buildExecutorRequest(task: FmRecord): Any
    fun buildNotifyRequest(task: FmRecord, status: Any): Any
    fun buildReassignRequest(wrapper: Any): Any
}

/**
 * Фабрика выбора стратегии
 */
@Component
class MonitoringProcessStrategyFactory(
    private val strategies: List<MonitoringProcessStrategy>
) {
    fun forProcessType(processType: ProcessType): MonitoringProcessStrategy =
        strategies.find { it.processType() == processType }
            ?: throw IllegalArgumentException("No strategy found for processType=$processType")
}

package ru.sber.poirot.focus.shared.dpa.strategy

import org.springframework.stereotype.Component
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.ProcessType.FOCUS_MONITORING
import ru.sber.poirot.dpa.model.ProcessType.MONITORING_KSB
import ru.sber.poirot.focus.shared.records.model.FmRecord

/**
 * Стратегия для старого процесса (FOCUS_MONITORING)
 */
@Component
class FocusMonitoringStrategy : MonitoringProcessStrategy {
    override fun processType(): ProcessType = FOCUS_MONITORING

    override fun buildExecutorRequest(task: FmRecord): Any {
        // здесь используешь FmDpaExecutorRequestBuilder (как было)
        return "executorRequest for FOCUS_MONITORING"
    }

    override fun buildNotifyRequest(task: FmRecord, status: Any): Any {
        // FmDpaNotifyRequestBuilder
        return "notifyRequest for FOCUS_MONITORING"
    }

    override fun buildReassignRequest(wrapper: Any): Any {
        // FmDpaReassignRequestBuilder
        return "reassignRequest for FOCUS_MONITORING"
    }
}

/**
 * Стратегия для нового процесса (MONITORING_KSB)
 */
@Component
class MonitoringKsbStrategy : MonitoringProcessStrategy {
    override fun processType(): ProcessType = MONITORING_KSB

    override fun buildExecutorRequest(task: FmRecord): Any {
        // TODO: твоя новая логика (бизнес-линия, параметры)
        return "executorRequest for MONITORING_KSB"
    }

    override fun buildNotifyRequest(task: FmRecord, status: Any): Any {
        // TODO: твоя новая логика
        return "notifyRequest for MONITORING_KSB"
    }

    override fun buildReassignRequest(wrapper: Any): Any {
        // TODO: твоя новая логика
        return "reassignRequest for MONITORING_KSB"
    }
}

package ru.sber.poirot.focus.shared.dpa.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import ru.sber.poirot.dpa.listen.DpaProcessTaskFetcher
import ru.sber.poirot.dpa.model.ProcessType
import ru.sber.poirot.dpa.model.ProcessType.FOCUS_MONITORING
import ru.sber.poirot.dpa.model.ProcessType.MONITORING_KSB
import ru.sber.poirot.focus.shared.dictionaries.model.MonitoringStatus.Companion.getStatusById
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.utils.logger

@Configuration
class FmDpaProcessConfig(
    private val fmDao: FmRecordDao
) {
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
    fun focusMonitoringProcessType(): ProcessType = FOCUS_MONITORING

    @Bean
    fun monitoringKsbProcessType(): ProcessType = MONITORING_KSB
}
