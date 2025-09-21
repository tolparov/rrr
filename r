
    @PostMapping("/uploadByFile")
    @PreAuthorize(HAS_INITIATION_FOCUS_MONITORING)
    suspend fun uploadByFile(@RequestPart file: FilePart): UploadResponse =
        auditClient.audit(event = "FOCUS_UPLOAD_INNS_FILE") {
            uploader.uploadByFile(file)
        }
package ru.sber.poirot.focus.upload.manual.uploader

import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.springframework.http.codec.multipart.FilePart
import org.springframework.stereotype.Service
import ru.sber.poirot.CurrentUser
import ru.sber.poirot.focus.shared.dictionaries.model.InputSource.MANUAL
import ru.sber.poirot.focus.shared.records.dao.FmRecordDao
import ru.sber.poirot.focus.upload.general.Default
import ru.sber.poirot.focus.upload.general.toFocusMonitoringRecord
import ru.sber.poirot.focus.upload.manual.*
import ru.sber.poirot.focus.upload.manual.VerifyEgrulStatus.EgrulNotFound
import ru.sber.poirot.focus.upload.manual.uploader.collect.DefaultCollector
import ru.sber.poirot.focus.upload.manual.uploader.parse.RequestParser
import ru.sber.poirot.focus.upload.manual.uploader.reject.RejectFilePreparer
import ru.sber.poirot.focus.upload.manual.uploader.validate.EventValidator
import ru.sber.poirot.focus.upload.manual.uploader.validate.InnValidator

@Service
class UploaderImpl(
    private val parser: RequestParser,
    private val innValidator: InnValidator,
    private val eventValidator: EventValidator,
    private val rejectFilePreparer: RejectFilePreparer,
    private val defaultCollector: DefaultCollector,
    private val focusDao: FmRecordDao,
    private val currentUser: CurrentUser
) : Uploader {
    override suspend fun verifyEgrulByInn(request: UploadRequest): VerifyEgrulStatus {
        val result = runCatching { innValidator.validate(request.wrap(), onError = { throw EgrulNotFound() }) }
        return when {
            result.exceptionOrNull() is EgrulNotFound -> VerifyEgrulStatus.EGRUL_MISSING
            else -> VerifyEgrulStatus.SUCCESS
        }
    }

    override suspend fun verifyDefaultByInn(request: UploadRequest): VerifyDefaultStatus =
        eventValidator.validate(request.inn)

    override suspend fun upload(request: UploadRequest) {
        val defaults = defaultCollector.collect(request).correct
        doUpload(defaults)
    }

    override suspend fun uploadByFile(file: FilePart): UploadResponse {
        val (clear, rejected) = parser.parse(file)
            .partition { it.hasNoError() }

        val result = defaultCollector.collectAll(clear.map { it.request })
        doUpload(result.correct)
        val errors = rejected.asUploadErrors() + result.rejected
        val rejectedFile = rejectFilePreparer.prepare(errors)

        return UploadResponse(
            fileName = file.filename(),
            success = result.correct.size,
            failed = errors.size,
            file = rejectedFile
        )
    }

    private suspend fun doUpload(defaults: List<Default>) {
        val login = currentUser.userName()
        val records = defaults.map { it.toFocusMonitoringRecord(MANUAL, login) }
        focusDao.insert(records)
    }

    companion object {
        val manualLoadLog: Logger = LoggerFactory.getLogger("ManualLoadLogger")
    }
}package ru.sber.poirot.focus.upload.manual

import java.util.*

private val base64Encoder: Base64.Encoder = Base64.getEncoder()

class UploadResponse(
    val fileName: String,
    val success: Int,
    val failed: Int,
    file: ByteArray,
) {
    val file = base64Encoder.encodeToString(file)
    val size: Int = success + failed
}package ru.sber.poirot.focus.upload.manual.uploader.parse

import org.springframework.http.codec.multipart.FilePart
import org.springframework.stereotype.Service
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.Dictionaries
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.INCORRECT_DELIMITER_OR_FILE_FORMAT
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.INCORRECT_FILE_FORMAT
import ru.sber.poirot.focus.upload.manual.UploadRequest
import ru.sber.poirot.focus.upload.manual.uploader.UploadRequestWrapper
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType.INCORRECT_INN_IN_FILE
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType.PROCESS_TYPE_NOT_FOUND
import ru.sber.poirot.focus.upload.manual.uploader.wrap
import ru.sber.poirot.webclient.readAsByteArray
import java.nio.charset.Charset.forName


@Service
class CsvRequestParser(val dictionaries: Dictionaries) : RequestParser {
    private val ignoreSymbols = listOf('\u000D')
    private val INVALID_PROCESS_TYPE = -1

    override suspend fun parse(file: FilePart): List<UploadRequestWrapper> {
        val lines = when (file.filename().substringAfterLast(".")) {
            "csv" -> read(file)
            else -> throwFileException(INCORRECT_FILE_FORMAT, file.filename())
        }

        return convert(lines).map { it.wrapWithChecks() }
    }

    private suspend fun read(file: FilePart): List<String> =
        String(file.readAsByteArray(), forName("Windows-1251"))
            .filter { it !in ignoreSymbols }
            .split("\n")
            .filter { it.isNotEmpty() }

    private suspend fun convert(lines: List<String>): List<UploadRequest> {
        val processTypeToCode = dictionaries.defaultProcessType().entries
            .associateBy({ it.value }) { it.key!! }

        val converted = lines.map { line -> uploadRequestFrom(line, processTypeToCode) }
        return when {
            converted.size <= 500 -> converted
            else -> converted.subList(0, 500)
        }
    }

    private fun UploadRequest.wrapWithChecks(): UploadRequestWrapper =
        wrap()
            .checkInn()
            .checkProcessType()

    private fun uploadRequestFrom(line: String, processTypeToCode: Map<String, Int>): UploadRequest {
        val split = line.split(";")
        if (split.size == 1) {
            throwFileException(INCORRECT_DELIMITER_OR_FILE_FORMAT)
        }

        val type = split[1].trim()
        val (inn, processType) = split[0] to (processTypeToCode[type] ?: INVALID_PROCESS_TYPE)

        return UploadRequest(inn, processType)
    }

    private fun UploadRequestWrapper.checkInn(): UploadRequestWrapper {
        val inn = request.inn
        if (inn.length != 10 && inn.length != 12) {
            errors.add(INCORRECT_INN_IN_FILE)
        }

        return this
    }

    private fun UploadRequestWrapper.checkProcessType(): UploadRequestWrapper {
        if (request.processType == INVALID_PROCESS_TYPE) {
            errors.add(PROCESS_TYPE_NOT_FOUND)
        }

        return this
    }

    private fun throwFileException(error: FocusErrorCode, param: String = ""): Nothing =
        throw FrontException(error, param)
}package ru.sber.poirot.focus.upload.manual.uploader.validate

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.metamodel.ibRegInfoEgrul
import ru.sber.poirot.engine.metamodel.leRegInfoEgrul
import ru.sber.poirot.focus.upload.manual.uploader.UploadRequestWrapper
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType.INN_NOT_FOUND_REG_INFO_EGRUL

@Service
class EgrulInnValidatorImpl : InnValidator {
    override suspend fun validateAll(
        wrappers: List<UploadRequestWrapper>,
        onError: (errorType: UploadErrorType) -> Unit
    ) {
        existIbOrLeRegInfoEgrul(wrappers, onError)
    }

    private suspend fun existIbOrLeRegInfoEgrul(
        wrappers: List<UploadRequestWrapper>,
        onError: (errorType: UploadErrorType) -> Unit
    ) {
        val inns = wrappers.map { it.inn }
        val ibExisted = ibRegInfoEgrulInns(inns)
        val leExisted = leRegInfoEgrulInns(inns)

        wrappers.forEach {
            val inn = it.inn
            if (!(ibExisted).contains(inn) && !leExisted.contains(inn)) {
                it.errors.add(INN_NOT_FOUND_REG_INFO_EGRUL)
                onError(INN_NOT_FOUND_REG_INFO_EGRUL)
            }
        }
    }

    private suspend fun ibRegInfoEgrulInns(inns: List<String>): Set<String> =
        (findAll(listOf(ibRegInfoEgrul.inn)) where {
            ibRegInfoEgrul.inn `in` inns
        }).convertTo { nextField<String>() }.toSet()

    private suspend fun leRegInfoEgrulInns(inns: List<String>): Set<String> =
        (findAll(listOf(leRegInfoEgrul.inn)) where {
            leRegInfoEgrul.inn `in` inns
        }).convertTo { nextField<String>() }.toSet()
}package ru.sber.poirot.focus.upload.manual.uploader.reject

import org.springframework.stereotype.Service
import ru.sber.poirot.csv.createCsv
import ru.sber.poirot.focus.shared.dictionaries.Dictionaries
import ru.sber.poirot.focus.upload.manual.uploader.UploadError

@Service
class RejectFilePreparerImpl(private val dictionaries: Dictionaries) : RejectFilePreparer {

    override suspend fun prepare(rejected: Collection<UploadError>): ByteArray {
        val processTypeByCode = dictionaries.defaultProcessType()

        return createCsv {
            rejected.forEach { wrapper ->
                wrapper.errors.forEach { reason ->
                    appendRow(
                        wrapper.inn,
                        processTypeByCode[wrapper.processType]
                            ?: "Некорректное значение кода процесса: ${wrapper.processType}",
                        reason.description
                    )
                }
            }
        }
    }
}package ru.sber.poirot.focus.shared.records.dao

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
}
