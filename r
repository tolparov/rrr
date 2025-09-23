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

    @Bean
    fun processType(): ProcessType = FOCUS_MONITORING
} мы можем тут смотреть тип задачи и взависимости от типа задачи нужный процесс тайп ставить 
