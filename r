package ru.sber.poirot.focus.stages

import org.springframework.stereotype.Service
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.focus.shared.dictionaries.inProcessFraudsCache
import ru.sber.poirot.focus.shared.dictionaries.model.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudCode.SUSPICION
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.*
import ru.sber.poirot.focus.shared.dictionaries.model.FraudScheme.Companion.fraudSchemes
import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.client.FraudManager
import ru.sber.poirot.fraud.client.KtorFraudClient
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.fraud.model.FraudRegistryType
import ru.sber.poirot.suspicion.dictionaries.fraudSchemeCorps
import ru.sber.utils.ifNotEmpty
import ru.sber.utils.logger
import java.time.LocalDate
import java.time.LocalDateTime

@Service
class FmFraudManager(private val ktorFraudClient: KtorFraudClient) : FraudManager<FmRecord> {
    private val log = logger()

    override suspend fun addFrauds(records: List<FmRecord>) {
        val inProcessFraudsByCode = inProcessFraudsCache.asMap()
        records.filter { it.confirmedFraud == true }
            .flatMap {
                it.fraudRecords(
                    fraudSchemes = fraudSchemes,
                    canBeDeleted = false,
                    inProcessFraud = inProcessFraudsByCode[it.inProcessFraud],
                )
            }
            .also { log.info("Adding ${it.size} fraud records:\n$it") }
            .ifNotEmpty { ktorFraudClient.addFrauds(it) }
    }

    override suspend fun editFrauds(recordPairs: List<FraudManager.RecordPair<FmRecord>>) {
        val inProcessFraudsByCode = inProcessFraudsCache.asMap()
        recordPairs
            .flatMap {
                it.new.fraudRecords(
                    fraudSchemes = it.getUpdatedFraudSchemes(),
                    canBeDeleted = true,
                    inProcessFraud = inProcessFraudsByCode[it.new.inProcessFraud]
                )
            }
            .also { log.info("Editing ${it.size} fraud records:\n$it") }
            .ifNotEmpty { ktorFraudClient.addFrauds(it) }
    }

    private fun FraudManager.RecordPair<FmRecord>.getUpdatedFraudSchemes(): List<FraudScheme> = buildList {
        if (new.capitalOutFlow != previous.capitalOutFlow) add(CAPITAL_OUTFLOW)
        if (new.bankruptcy != previous.bankruptcy) add(BANKRUPTCY)
        if (new.fakeReportDoc != previous.fakeReportDoc) add(FAKE_DOC)
        if (new.fakeReport != previous.fakeReport) add(FAKE_REPORT)
        if (new.inProcessFraud != previous.inProcessFraud
            || new.summary != previous.summary
            || new.summaryKp != previous.summaryKp
            || new.dateFraud != previous.dateFraud
        ) {
            if (new.capitalOutFlow?.isNotEmpty == true) add(CAPITAL_OUTFLOW)
            if (new.bankruptcy?.isNotEmpty == true) add(BANKRUPTCY)
            if (new.fakeReportDoc?.isNotEmpty == true) add(FAKE_DOC)
            if (new.fakeReport?.isNotEmpty == true) add(FAKE_REPORT)
        }
    }.distinct()

    private fun FmRecord.fraudRecords(
        fraudSchemes: List<FraudScheme>,
        canBeDeleted: Boolean,
        inProcessFraud: String?,
    ): List<FraudRecord> {
        val fraudReasonsCorp = fraudSchemeCorps.asSet().toList()
        val fraudReasonsCorps = FraudScheme.fraudSchemes
        return if (processType == 11 && !monitoringProcessFraudSchemas.isNullOrEmpty()) {
            val monitoringFrauds = monitoringProcessFraudSchemas.map { scheme ->
                val fraudScheme = fraudReasonsCorp.firstOrNull { scheme.fraudSchemeId == it.id }
                    ?: throw FrontException("Такого фрод признака не существует: fraudSchemeId=${scheme.fraudSchemeId}")
                FraudRecord.fraudRecord(
                    type = FraudRegistryType.LE_CLIENT.type,
                    key = inn!!,
                    keyNoApp = inn,
                    fraudStatus = SUSPICION.code,
                    scheme = fraudScheme.key,
                    source = "monitoring_ksb",
                    fullComment = scheme.fullComment ?: summary,
                    shortComment = scheme.shortComment ?: summaryKp,
                    login = executor,
                    dateTime = LocalDateTime.now(),
                    typeFraud = "Последующий",
                    incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                    corpControlMode = fmFraudCorpControlMode,
                    fraudAdditionalInfo = null
                )
            }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                gfmFraudSource,
                executor ?: throw FrontException("Исполнитель должен быть назначен"),
                gfmTypeFraud
            )

            (monitoringFrauds + fraudsBySuspicions).distinct()
        } else {
            val generalFrauds = fraudSchemes.mapNotNull { it.fraudRecord(this, canBeDeleted, inProcessFraud) }
            val fraudsBySuspicions = fraudRecordsBySuspicions(
                fraudReasonsCorp,
                fmFraudSource,
                fmFraudLogin,
                typeFraud(inProcessFraud)
            )
            (generalFrauds + fraudsBySuspicions).distinct()
        }
    }

    private fun FmRecord.fraudRecordsBySuspicions(
        fraudSchemes: List<FraudReasonsCorp>,
        source: String?,
        login: String,
        typeFraud: String?
    ): List<FraudRecord> = suspicions.suspicions(fraudSchemes)
        .suspicionEntities()
        .map { suspicionEntity ->
            val fraudKey = suspicionEntity.fraudKey()
            FraudRecord.fraudRecord(
                type = fraudKey.type,
                key = fraudKey.key,
                keyNoApp = fraudKey.key,
                fraudStatus = SUSPICION.code,
                scheme = fraudKey.scheme,
                source = source,
                fullComment = summary,
                shortComment = summaryKp,
                login = login,
                dateTime = LocalDateTime.now(),
                typeFraud = typeFraud,
                incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
                corpControlMode = fmFraudCorpControlMode,
                fraudAdditionalInfo = null,
            )
        }
}
package ru.sber.poirot.focus.shared.dictionaries.model

import ru.sber.poirot.focus.shared.records.model.FmRecord
import ru.sber.poirot.fraud.model.FraudRecord
import ru.sber.poirot.fraud.model.FraudRecord.Companion.fraudRecord
import ru.sber.poirot.fraud.model.FraudRegistryType.LE_CLIENT
import java.time.LocalDate
import java.time.LocalDateTime

enum class FraudScheme(val id: Int, val code: String, val scheme: String) {

    CAPITAL_OUTFLOW(1, "capital_outflow", "Вывод капитала") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf {
                canBeDeleted || with(it.capitalOutFlow) { this != null && startDate != null && comment != null }
            }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.capitalOutFlow?.startDate == null,
                    affectedByDefault = record.capitalOutFlow?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = listOfNotNull(record.capitalOutFlow?.startDate),
                fraudInfluenceOnDefault = record.capitalOutFlow?.affectedByDefault ?: false,
            )
    },
    BANKRUPTCY(2, "bankruptcy", "Преднамеренное/фиктивное банкротство") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf {
                canBeDeleted || with(it.bankruptcy) { this != null && affectedDate != null && sign != null }
            }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.bankruptcy?.affectedDate == null,
                    affectedByDefault = record.bankruptcy?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = listOfNotNull(record.bankruptcy?.affectedDate),
                fraudInfluenceOnDefault = record.bankruptcy?.affectedByDefault ?: false,
            )
    },
    FAKE_DOC(3, "fake_doc", "Фальсификация документов") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf { canBeDeleted || with(it.fakeReportDoc) { this != null && affectedDate != null } }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.fakeReportDoc?.affectedDate == null,
                    affectedByDefault = record.fakeReportDoc?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = listOfNotNull(record.fakeReportDoc?.affectedDate),
                fraudInfluenceOnDefault = record.fakeReportDoc?.affectedByDefault ?: false,
            )
    },
    FAKE_REPORT(4, "fake_report", "Фальсификация отчетности") {
        override fun fraudRecord(
            record: FmRecord,
            canBeDeleted: Boolean,
            inProcessFraud: String?,
        ): FraudRecord? = record
            .takeIf {
                canBeDeleted || with(it.fakeReport) { this != null && affectedDates.isNotEmpty() && affectedByDefault != null }
            }
            ?.makeFraudRecord(
                inProcessFraud = inProcessFraud,
                scheme = code,
                fraudStatus = FraudCode.from(
                    isEmpty = record.fakeReport?.affectedDates.isNullOrEmpty(),
                    affectedByDefault = record.fakeReport?.affectedByDefault,
                    confirmedFraud = record.confirmedFraud.takeIf { canBeDeleted },
                ),
                fraudAdditionalDates = record.fakeReport?.affectedDates ?: emptyList(),
                fraudInfluenceOnDefault = record.fakeReport?.affectedByDefault ?: false,
            )
    };

    abstract fun fraudRecord(record: FmRecord, canBeDeleted: Boolean, inProcessFraud: String?): FraudRecord?

    companion object {
        val fraudSchemes = entries.toList()
        private val fraudSchemeById: Map<Int?, FraudScheme> = fraudSchemes.associateBy { it.id }

        val fraudSchemeValueById: Map<Int?, String> = fraudSchemeById.mapValues { it.value.scheme }
        val fraudSchemeIdByCode: Map<String, Int> = fraudSchemes.associate { it.code to it.id }

        fun fraudSchemeCodeById(id: Int): String =
            fraudSchemeById[id]?.code ?: throw IllegalStateException("Incorrect fraud scheme id: $id")
    }
}

const val fmFraudCorpControlMode: String = "off-line"
const val fmFraudSource: String = "focus_monitoring"
const val fmFraudLogin: String = "autocomplete_focus_monitoring"
const val gfmFraudSource: String = "monitoring_ksb"
const val gfmTypeFraud: String = "Последующий"


fun typeFraud(inProcessFraud: String?): String = when (inProcessFraud) {
    "Предкредитка" -> "Преднамеренный"
    else -> "Последующий"
}

private fun FmRecord.makeFraudRecord(
    inProcessFraud: String?,
    scheme: String,
    fraudStatus: String?,
    fraudAdditionalDates: List<LocalDate> = emptyList(),
    fraudInfluenceOnDefault: Boolean,
): FraudRecord? = when {
    fraudStatus == null -> null
    else -> fraudRecord(
        type = LE_CLIENT.type,
        key = inn!!,
        keyNoApp = inn,
        fraudStatus = fraudStatus,
        scheme = scheme,
        source = fmFraudSource,
        fullComment = summary,
        shortComment = summaryKp,
        login = fmFraudLogin,
        typeFraud = typeFraud(inProcessFraud),
        dateTime = LocalDateTime.now(),
        incomingDate = dateApproval?.toLocalDate() ?: LocalDate.now(),
        corpControlMode = fmFraudCorpControlMode,
        fraudAdditionalInfo = dateFraud?.let {
            FraudRecord.FraudAdditionalInfo(
                fraudStartDate = dateFraud,
                fraudInfluenceOnDefault = fraudInfluenceOnDefault,
                fraudAdditionalDates = fraudAdditionalDates,
            )
        },
    )
}     @file:InitRefreshables

package ru.sber.poirot.suspicion.dictionaries

import ru.sber.poirot.engine.dictionaries.metamodel.fraudReasonsCorp
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp
import ru.sber.poirot.engine.ds.refreshable.RefreshableSet
import ru.sber.poirot.engine.ds.refreshable.delayers.about30Min
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.invoke
import ru.sber.poirot.refreshable.InitRefreshables
import ru.sber.poirot.refreshable.dictionaryRefreshableSet

val fraudSchemeCorps: RefreshableSet<FraudReasonsCorp> = dictionaryRefreshableSet(
    name = "fraudSchemeCorps",
    refresh = about30Min()
) {
    findAll(fraudReasonsCorp, batch = false) fetchFields { allFields } where {
        fraudReasonsCorp {
            id.isNotNull()
        }
    }
}package ru.sber.poirot.engine.dictionaries.metamodel
            
import ru.sber.poirot.engine.dsl.Filter
import ru.sber.poirot.engine.dsl.ContextHolder
import ru.sber.poirot.engine.dsl.MetaModel
import ru.sber.poirot.engine.dsl.metamodel.*
import ru.sber.poirot.engine.dsl.metamodel.MetaModelOf
import java.util.Collections.emptyList
import java.time.*
import ru.sber.poirot.engine.dictionaries.model.api.fraud.FraudReasonsCorp

class FraudReasonsCorpMM(
    private val currentMM: MetaModelOf<FraudReasonsCorp>,
    private val currentFields: List<Any> = listOf(
        "key".toField<String>(currentMM),
        "name".toField<String>(currentMM),
        "id".toField<Int>(currentMM),
    ),
    override var context: MutableList<Filter>
) : MetaModel<FraudReasonsCorp> by currentMM, ContextHolder {
    constructor(path: String, parent: MetaModel<*>?) : this(MetaModelOf(path, FraudReasonsCorpMM::class.java, FraudReasonsCorp::class.java, parent), context = emptyList())

    val key get() = field<String>(currentFields[0], context)
    val name get() = field<String>(currentFields[1], context)
    val id get() = field<Int>(currentFields[2], context)

    val allFields
        get() = listOf(
            key,
            name,
            id
        )

    override fun copy(context: MutableList<Filter>): FraudReasonsCorpMM = FraudReasonsCorpMM(currentMM, currentFields, context)
    override fun equals(other: Any?): Boolean = this === other || currentMM == other
    override fun hashCode(): Int = currentMM.hashCode()
    override fun toString(): String = currentMM.toString()
}

val fraudReasonsCorp = FraudReasonsCorpMM("FraudReasonsCorp", null)
val ContextHolder.fraudReasonsCorp get() = fraudReasonsCorp().copy(context = this.context)
private fun fraudReasonsCorp() = fraudReasonsCorp
 мне нужно чтоб  fraudScheme в этом методе  rivate fun FmRecord.fraudRecords  получал список фрод признаков из двух списков и самое главное там будут дубликаты дубликаты нужна убрать именно из этого списка fraudReasonsCorp и оставить совпадающие записи из fraudReasonsCorps и потом использовать общий список для дальнейшей логики
