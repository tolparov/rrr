package ru.sber.poirot.focus.upload.manual.uploader.collect.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.focusMonitoringRecord
import ru.sber.poirot.focus.upload.manual.uploader.UploaderImpl.Companion.manualLoadLog
import ru.sber.poirot.utils.withMeasurement

@Repository
class DslCollectorDao : CollectorDao {
    override suspend fun findInnToStatuses(inns: List<String>): Triple(Strin) =
        withMeasurement("Found inn to status by inns", logger = manualLoadLog, constraintInMs = 100) {
            (findAll(entity = focusMonitoringRecord, batch = false) fetchFields {
                listOf(inn, status, processType)
            } where {
                focusMonitoringRecord.inn `in` inns
            }).let { Triple(it.inn, it.status,  it.processType) }
        }
} допиши 
было вот так package ru.sber.poirot.focus.upload.manual.uploader.collect.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.focusMonitoringRecord
import ru.sber.poirot.focus.upload.manual.uploader.UploaderImpl.Companion.manualLoadLog
import ru.sber.poirot.utils.withMeasurement

@Repository
class DslCollectorDao : CollectorDao {
    override suspend fun findInnToStatuses(inns: List<String>): Map<String, List<Int?>> =
        withMeasurement("Found inn to status by inns", logger = manualLoadLog, constraintInMs = 100) {
            (findAll(entity = focusMonitoringRecord, batch = false) fetchFields {
                listOf(inn, status)
            } where {
                focusMonitoringRecord.inn `in` inns
            }).groupBy({ it.inn }, { it.status })
        }
}
