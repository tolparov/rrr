package ru.sber.poirot.focus.shared.records.dao

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.datasources.PoirotDatabaseNames.POIROT_PKAP
import ru.sber.poirot.engine.datasources.transaction.TransactionTemplates
import ru.sber.poirot.engine.datasources.transaction.inTransactionSuspend
import ru.sber.poirot.engine.dsl.*
import ru.sber.poirot.engine.dsl.metamodel.PrimitiveField
import ru.sber.poirot.engine.metamodel.focusMonitoringRecord
import ru.sber.poirot.engine.model.api.monitoring.FocusMonitoringRecord
import ru.sber.poirot.engine.model.full.monitoring.FakeReportDate
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.focus.shared.records.model.FmRecord.Companion.toFocusRecord
import ru.sber.poirot.focus.shared.records.model.FmRecordInfo
import ru.sber.poirot.focus.shared.records.model.toRecordInfo
import ru.sber.poirot.utils.withMeasurement
import ru.sber.sql.persister.AsyncGraphPersister
import ru.sber.utils.logger
import ru.sber.poirot.engine.model.api.monitoring.FakeReportDate as ApiFakeReportDate

@Service
class DslFmRecordDao(
    private val persister: AsyncGraphPersister,
    private val transactionTemplates: TransactionTemplates,
) : FmRecordDao {
    private val log = logger()

    override suspend fun findRecordInfos(
        filter: Filter,
        orderBy: PrimitiveField<*>,
        order: Order,
        limit: Int,
    ): List<FmRecordInfo> =
        withMeasurement(message = "Find focus monitoring record infos", logger = log) {
            (findAll(
                entity = focusMonitoringRecord,
                order = order,
                orderBy = listOf(orderBy),
                limit = limit,
                batch = false
            ) fetchFields { listOf(id) } where {
                filter
            }).map { it.toRecordInfo() }
        }

    override suspend fun findRecordBy(recordId: Long): FmRecord? =
        withMeasurement(message = "Find focus monitoring record by id", logger = log) {
            (findFirst(entity = focusMonitoringRecord, batch = false) fetchFields {
                allFieldsWithRelations
            } where {
                id `=` recordId
            })?.toFocusRecord()
        }

    override suspend fun findRecordsBy(recordIds: List<Long>): List<FmRecord> =
        withMeasurement(message = "Find focus monitoring records by ids", logger = log) {
            (findAll(entity = focusMonitoringRecord, batch = false) fetchFields {
                allFieldsWithRelations
            } where {
                id `in` recordIds
            }).map { it.toFocusRecord() }
        }

    override suspend fun <R> findRecordAttributes(
        recordIds: List<Long>,
        fields: List<PrimitiveField<*>>,
        convert: (FocusMonitoringRecord) -> R,
    ): List<R> = withMeasurement(message = "Get focus monitoring records attributes", logger = log) {
        (findAll(entity = focusMonitoringRecord, batch = false) fetchFields {
            fields
        } where {
            id `in` recordIds
        }).map(convert)
    }

    override suspend fun findRecordBy(recordId: Long, statuses: List<Int>): FmRecord? =
        withMeasurement(message = "Find focus monitoring record by id and statuses", logger = log) {
            (findFirst(entity = focusMonitoringRecord, batch = false) fetchFields {
                allFieldsWithRelations
            } where {
                id `=` recordId
                status `in` statuses
            })?.toFocusRecord()
        }

    override suspend fun findRecordBy(
        recordId: Long,
        statuses: List<Int>,
        executorLogin: String,
    ): FmRecord? =
        withMeasurement(message = "Find focus monitoring record by id, statuses and login", logger = log) {
            (findFirst(entity = focusMonitoringRecord, batch = false) fetchFields {
                allFieldsWithRelations
            } where {
                id `=` recordId
                executor `=` executorLogin
                status `in` statuses
            })?.toFocusRecord()
        }

    override suspend fun existsInStatus(recordId: Long, statusParam: Int): Boolean =
        withMeasurement(message = "Exists focus monitoring record with id and status", logger = log) {
            existsAny(focusMonitoringRecord, batch = false) where {
                id `=` recordId
                status `=` statusParam
            }
        }

    override suspend fun merge(record: FocusMonitoringRecord) {
        persister.merge(listOf(record))
    }

    override suspend fun mergeWithChildren(record: FocusMonitoringRecord) {
        transactionTemplates[POIROT_PKAP].inTransactionSuspend {
            val oldIds = getFakeReportDates(record.id)?.map { it.id } ?: emptyList()
            val newIds = record.fakeReport?.affectedDates?.map { it.id } ?: emptyList()
            persister.deleteByIds(FakeReportDate::class.java, oldIds - newIds.toSet())
            persister.merge(listOf(record))
        }
    }

    private suspend fun getFakeReportDates(recordId: Long): List<ApiFakeReportDate>? =
        (findFirst(
            focusMonitoringRecord,
            batch = false,
        ) fetchFields {
            fakeReport.affectedDates.allFields
        } where {
            id `=` recordId
        })?.fakeReport?.affectedDates

    override suspend fun merge(records: List<FocusMonitoringRecord>): Unit = persister.merge(records)

    override suspend fun insert(records: List<FocusMonitoringRecord>): Unit = persister.insert(records)
}package ru.sber.sql.persister.async

import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.withContext
import org.springframework.context.annotation.Primary
import org.springframework.stereotype.Service
import org.springframework.transaction.support.TransactionSynchronizationManager.isActualTransactionActive
import ru.sber.jpa.databaseName
import ru.sber.poirot.engine.datasources.DataSources
import ru.sber.poirot.engine.datasources.PoirotDataSource
import ru.sber.sql.persister.AsyncGraphPersister
import ru.sber.sql.persister.GraphPersister
import ru.sber.sql.persister.sync.SkipStrategy
import ru.sber.utils.newNamedForkJoinDispatcher
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger
import javax.sql.DataSource
import kotlin.reflect.KFunction1

@Primary
@Service
class AsyncGraphPersisterImpl(
    override val persister: GraphPersister,
    private val dataSources: DataSources
) : AsyncGraphPersister {
    private val ioDispatchers = ConcurrentHashMap<DataSource, CoroutineDispatcher>()

    override suspend fun insert(entities: List<*>, skip: SkipStrategy): Unit =
        changeContextIfNotTransactional(entities) {
            persister.insert(entities, skip)
        }

    override suspend fun <T> insertChildrenOf(
        parents: List<T>,
        childrenGetter: KFunction1<T, List<*>>,
        skip: SkipStrategy,
    ): Unit = changeContextIfNotTransactional(parents) {
        persister.insertChildrenOf(parents, childrenGetter, skip)
    }

    override suspend fun merge(entities: List<*>, skip: SkipStrategy): Unit =
        changeContextIfNotTransactional(entities) {
            persister.merge(entities, skip)
        }

    override suspend fun deleteById(entityClass: Class<*>, id: Any): Boolean =
        changeContextIfNotTransactional(entityClass) {
            persister.deleteById(entityClass, id)
        }

    override suspend fun deleteByIds(entityClass: Class<*>, ids: List<Any>): Int =
        changeContextIfNotTransactional(entityClass) {
            persister.deleteByIds(entityClass, ids)
        }

    private suspend fun changeContextIfNotTransactional(entities: List<*>, block: () -> Unit) =
        entities.firstNotNullOfOrNull { it }?.javaClass?.let {
            changeContextIfNotTransactional(it, block)
        } ?: Unit

    private suspend fun <T> changeContextIfNotTransactional(cls: Class<*>, block: () -> T): T = when {
        isActualTransactionActive() -> block()
        else -> withContext(
            ioDispatchers.computeIfAbsent(dataSources.dataSource(cls.databaseName())) { dataSource ->
                val database: String = (dataSource as? PoirotDataSource)?.config?.database
                    ?: unknownDataSourceNumber.getAndIncrement().toString()
                newNamedForkJoinDispatcher(
                    prefix = "persister-$database-",
                    poolSize = (dataSource as? PoirotDataSource)?.config?.hikariConnections?.maxHikari ?: 30
                )
            }
        ) { block() }
    }

    private val unknownDataSourceNumber = AtomicInteger()
} Изменения в логике трех АПИ /focus-monitoring/api/inwork/send-to-agreement, /focus-monitoring/api/edit и /focus-monitoring/api/inwork/save:
сохранять массив InWorkRequest.monitoringProcessFraudSchemas в БД в таблицу focus_monitoring.monitoring_process_fraud_scheme

focus_monitoring.monitoring_process_fraud_scheme.id	Технический id, автоинкремент
focus_monitoring.monitoring_process_fraud_scheme.focus_monitoring_record_id	
Внешний ключ на задачу

focus_monitoring.focus_monitoring_record.id

focus_monitoring.monitoring_process_fraud_scheme.scheme	
Берем из запроса АПИ InWorkRequest.monitoringProcessFraudSchemas.fraudSchemeId
Находим соответствующую запись из справочника re_dictionaries.fraud_reasons_corp по id =fraudSchemeId
Используем re_dictionaries.fraud_reasons_corp.key
focus_monitoring.monitoring_process_fraud_scheme.full_comment	из запроса апи InWorkRequest.monitoringProcessFraudSchemas.fullComment
focus_monitoring.monitoring_process_fraud_scheme.short_comment	из запроса апи InWorkRequest.monitoringProcessFraudSchemas.shortComment
если записей ранее не было, то вставляем записи из запроса, если были, то удаляем все записи по задаче и добавляем записи из запроса
