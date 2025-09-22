package ru.sber.poirot.focus.upload.manual.uploader.parse

import org.springframework.http.codec.multipart.FilePart
import org.springframework.stereotype.Service
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.Dictionaries
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.INCORRECT_DELIMITER_OR_FILE_FORMAT
import ru.sber.poirot.focus.shared.infra.error.FocusErrorCode.INCORRECT_FILE_FORMAT
import ru.sber.poirot.focus.upload.manual.UploadRequest
import ru.sber.poirot.focus.upload.manual.uploader.UploadRequestWrapper
import ru.sber.poirot.focus.upload.manual.uploader.collect.UploadErrorType.SLA_REQUIRED
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
            .checkSlaIfMonitoring()

    private fun uploadRequestFrom(line: String, processTypeToCode: Map<String, Int>): UploadRequest {
        val split = line.split(";")
        if (split.size < 2) {
            throwFileException(INCORRECT_DELIMITER_OR_FILE_FORMAT)
        }

        val inn = split[0].trim()
        val type = split[1].trim()
        val processType = processTypeToCode[type] ?: INVALID_PROCESS_TYPE

        val slaByDefault = split.getOrNull(2)?.trim()?.takeIf { it.isNotEmpty() }?.toIntOrNull()
        val initiatorComment = split.getOrNull(3)?.trim()?.takeIf { it.isNotEmpty() }

        return UploadRequest(inn, processType, slaByDefault, initiatorComment)
    }

    private fun UploadRequestWrapper.checkInn(): UploadRequestWrapper {
        val inn = request.inn
        if (inn.length != 10 && inn.length != 12) {
            errors.add(INCORRECT_INN_IN_FILE)
        }

        return this
    }

    private fun UploadRequestWrapper.checkSlaIfMonitoring(): UploadRequestWrapper {
        val processTypeId = request.processType

        if (processTypeId == 11 && request.slaByDefault == null) {
            errors.add(SLA_REQUIRED)
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
} нужно чтоб slaByDefault был равен одному из значейний enum package ru.sber.poirot.focus.shared.dictionaries.model

enum class SlaByDefault(val id: Int, val hours: String) {
    FIVE_HALF(1, "5.5 ч."),
    EIGHT(2, "8 ч."),
    TWELVE(3, "12 ч.");

    companion object {
        fun asMap(): Map<Int?, String> = entries.associate { it.id to it.hours }

        fun getHoursById(id: Int): String = entries.find { it.id == id }?.hours
            ?: throw IllegalArgumentException("SLA с id=$id не найдено")
    }
} а иначе ошибка 
