package ru.sber.poirot.grs.scheme.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.inlined
import ru.sber.poirot.engine.metamodel.*
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.INCORRECT_ROW_SIZE
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.grs.participant.dto.FlDebtDto
import ru.sber.poirot.grs.participant.dto.OrgInfoDto
import ru.sber.poirot.grs.participant.dto.ParticipantDto
import ru.sber.poirot.grs.participant.dto.UlDebtDto
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.time.temporal.ChronoUnit

@Repository
class ParticipantInfoFetcher {
    suspend fun fetchFraudStatuses(inns: List<String>, fioDobs: List<String>): Map<String, String> =
        (findAll(entity = fraud, batch = true) fetchFields {
            listOf(fraud.key, fraud.fraudStatus, fraud.dateTime)
        } where {
            (fraud.type `=` "ЮЛ:КлиентОрганизация" and (fraud.key `in` inns)) or
                    (fraud.type `=` "ЮЛ:ФИОДР" and (fraud.key `in` fioDobs))
        }).groupBy { it.key }
            .mapValues { (_, features) ->
                features.maxWith(
                    compareBy(
                        { it.fraudStatus?.priority() ?: Int.MAX_VALUE },
                        { it.dateTime ?: LocalDateTime.MIN }
                    )
                ).fraudStatus
            }
            .filterValues { it != null }

    suspend fun fetchOrgInfos(inns: List<String>): List<OrgInfoDto?> {
        val ulResults = fetchLEInfo(inns)
        val ipResults = fetchIPInfo(inns)
        return (ulResults + ipResults).filterNotNull()
    }

    suspend fun fetchFounders(ogrnList: List<String>): Map<String, List<ParticipantDto.FounderDto>> {
        val allFounders = findAll(
            entity = leFoundersEgrul,
            batch = true
        ) fetchFields {
            listOf(
                leFoundersEgrul.compOgrn,
                leFoundersEgrul.founderInn,
                leFoundersEgrul.founderName,
                leFoundersEgrul.dateActual
            )
        } where {
            leFoundersEgrul.compOgrn `in` ogrnList
        }

        // 2. Находим максимальные даты для каждого OGRN
        val maxDatesByOgrn = allFounders
            .groupBy { it.compOgrn }
            .mapValues { (_, founders) ->
                founders.maxOf { it.dateActual }
            }

        // 3. Фильтруем учредителей по максимальной дате
        return allFounders
            .groupBy { it.compOgrn }
            .mapValues { (ogrn, founders) ->
                founders
                    .filter { it.dateActual == maxDatesByOgrn[ogrn] }
                    .map { ParticipantDto.FounderDto(it.founderInn, it.founderName) }
            }
            .filterValues { it.isNotEmpty() }
    }

    suspend fun fetchUlDebts(inns: List<String>): List<UlDebtDto> =
        findAll(
            fields = listOf(
                arrearsClientUl.inn,
                arrearsAgreement.debtAmount,
                arrearsAgreement.curDebtOverAmount,
                arrearsAgreement.curPercOverAmount,
                arrearsAgreement.curDebtOverDate,
                arrearsAgreement.curPercOverDate
            ),
            batch = true
        ) join {
            arrearsRoleLink.customerId `=` arrearsClientUl.customerId
            arrearsAgreement.agreementId `=` arrearsRoleLink.agreementId
        } where {
            arrearsClientUl.inn `in` inns and
                    arrearsRoleLink.role `=` "Заемщик"
        } convertTo {
            UlDebtDto(
                clientInn = nextField(),
                totalCurrentDebt = nextField(),
                totalOverdueDebt = (nextField<Double>() + nextField<Double>()),
                prncpOverdueDays = daysBetweenToday(nextField()),
                intrstOverdueDays = daysBetweenToday(nextField())
            )
        }


    suspend fun fetchFlDebts(fioDobs: List<String>): List<FlDebtDto> {
        return fioDobs.flatMap { fioDob ->
            val parts = fioDob.split("|")
            when {
                parts.size !in 3..4 -> throw FrontException(INCORRECT_ROW_SIZE.description)
                else -> {
                    val lastName = parts[0]
                    val firstName = parts[1]
                    val middleName = parts.getOrNull(2)?.takeIf { it.isNotBlank() }
                    val birthDate = LocalDate.parse(
                        parts.last(),
                        DateTimeFormatter.ofPattern("dd.MM.yyyy")
                    )

                    val clients = findAll(entity = arrearsClientFl, batch = false) fetchFields {
                        listOf(arrearsClientFl.customerId)
                    } where {
                        arrearsClientFl.lastName `=` lastName.inlined and
                                arrearsClientFl.firstName `=` firstName.inlined and
                                arrearsClientFl.birthDate `=` birthDate.inlined and
                                (middleName?.let { arrearsClientFl.middleName `=` it.inlined }
                                    ?: arrearsClientFl.middleName.isNull())
                    }

                    clients.flatMap { client ->
                        findAll(
                            fields = listOf(
                                arrearsAgreement.agreementId,
                                arrearsAgreement.debtAmount,
                                arrearsAgreement.curDebtOverAmount,
                                arrearsAgreement.curPercOverAmount,
                                arrearsAgreement.curDebtOverDate,
                                arrearsAgreement.curPercOverDate
                            ), batch = false
                        ) join {
                            arrearsRoleLink.customerId `=` client.customerId.inlined and
                                    arrearsAgreement.agreementId `=` arrearsRoleLink.agreementId
                        } where {
                            arrearsRoleLink.role `=` "Заемщик".inlined
                        } convertTo {
                            FlDebtDto(
                                agreementId = nextField(),
                                clientFioDob = fioDob,
                                totalCurrentDebt = nextField(),
                                totalOverdueDebt = nextField<Double>() + nextField<Double>(),
                                prncpOverdueDays = daysBetweenToday(nextField()),
                                intrstOverdueDays = daysBetweenToday(nextField())
                            )
                        }
                    }
                }
            }
        }
    }

        suspend fun fetchRelatedSchemes(ids: List<Long>, currentSchemeId: Long): Map<Long, List<String>> =
            (findAll(
                fields = listOf(
                    fraudScheme.participantsMapping.participant.id,
                    fraudScheme.name
                ),
                batch = true
            ) where {
                fraudScheme.participantsMapping.participant.id `in` ids
                fraudScheme.id `!=` currentSchemeId.inlined
            } convertTo {
                val participantId = nextField<Long>()
                val schemeName = nextField<String>()
                participantId to schemeName
            }).groupBy(
                { it.first },  // participantId
                { it.second }  // schemeName
            )


    private suspend fun fetchLEInfo(inns: List<String>): List<OrgInfoDto?> =
        (findAll(fields = with(leRegInfoEgrul) {
            listOf(
                leRegInfoEgrul.inn,
                leRegInfoEgrul.ogrn,
                leRegInfoEgrul.dateReg,
                leRegInfoEgrul.region,
                leRegInfoEgrul.regionType,
                leRegInfoEgrul.briefOrganizationName,
                leRegInfoEgrul.fullOrganizationName
            )
        }, batch = false) where {
            leRegInfoEgrul.inn `in` inns and
                    (leRegInfoEgrul.leCode.isNull() or leRegInfoEgrul.leCode `not in` listOf(
                        "701",
                        "702",
                        "801"
                    ).inlined) and
                    (leRegInfoEgrul.leEndCode.isNull() or leRegInfoEgrul.leEndCode `not in` listOf(
                        "701",
                        "801"
                    ).inlined)

        } convertTo {
            OrgInfoDto(
                inn = nextField(),
                ogrn = nextField(),
                registrationDate = nextField(),
                region = buildRegionString(nextField(), nextField()),
                name = nextField() ?: nextField()
            )
        }).groupBy { it.inn }
            .map { (_, infos) -> infos.maxByOrNull { it.registrationDate!! } }

    private suspend fun fetchIPInfo(inns: List<String>): List<OrgInfoDto?> =
        (findAll(fields = with(ibRegInfoEgrul) {
            listOf(
                ibRegInfoEgrul.inn,
                ibRegInfoEgrul.ogrnip,
                ibRegInfoEgrul.egripRecDate,
                ibRegInfoEgrul.regionName,
                ibRegInfoEgrul.regionType,
                ibRegInfoEgrul.lastName,
                ibRegInfoEgrul.firstName,
                ibRegInfoEgrul.secondName
            )
        }, batch = false) where {
            ibRegInfoEgrul.inn `in` inns and
                    (ibRegInfoEgrul.ipStatusCode.isNull() or ibRegInfoEgrul.ipStatusCode `=` "")
        } convertTo {
            val inn = nextField<String>()
            val ogrn = nextField<String?>()
            val regDate = nextField<LocalDate?>()
            val region = buildRegionString(nextField(), nextField())
            val lastName = nextField<String?>()
            val firstName = nextField<String?>()
            val secondName = nextField<String?>()

            val name = when {
                !lastName.isNullOrBlank() && !firstName.isNullOrBlank() -> {
                    "ИП $lastName $firstName${secondName?.let { " $it" }.orEmpty()}"
                }
                else -> "Отсутствуют данные"
            }

            OrgInfoDto(
                inn = inn,
                ogrn = ogrn,
                registrationDate = regDate,
                region = region,
                name = name
            )
        }).groupBy { it.inn }
            .map { (_, infos) -> infos.maxByOrNull { it.registrationDate!! } }

    private fun daysBetweenToday(date: LocalDate?): Int =
        date?.let { ChronoUnit.DAYS.between(it, LocalDate.now()).toInt() } ?: 0

    private fun buildRegionString(regionPart1: String?, regionPart2: String?): String? =
        when {
            regionPart1 != null && regionPart2 != null -> "$regionPart1 $regionPart2"
            regionPart1 != null -> regionPart1
            regionPart2 != null -> regionPart2
            else -> null
        }

    private fun String.priority(): Int = when (this) {
        "fraud" -> 9
        "suspicion" -> 8
        "in_work" -> 7
        "risk_digital_footprint" -> 6
        "risk_grey_zone" -> 5
        "risk" -> 4
        "remove_mon" -> 3
        "remove" -> 2
        "clear" -> 1
        else -> 0
    }

}
package ru.sber.poirot.grs.shared.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.dsl.inlined
import ru.sber.poirot.engine.metamodel.taskRegistry
import ru.sber.poirot.grs.scheme.dto.TaskInfoDto
import ru.sber.poirot.grs.shared.model.GroupsRelatedScams
import ru.sber.poirot.grs.shared.model.GroupsRelatedScamsStatus.DELETED
import ru.sber.poirot.grs.shared.model.toDto
import ru.sber.poirot.grs.shared.model.toEntity
import ru.sber.poirot.utils.withMeasurement
import ru.sber.sql.persister.AsyncGraphPersister
import ru.sber.utils.logger

@Repository
class DslGrsDao(
    private val asyncPersister: AsyncGraphPersister
) : GrsDao {
    private val log = logger()

    override suspend fun insert(grs: GroupsRelatedScams) {
        val grsRecord = grs.toEntity()
        asyncPersister.insert(listOf(grsRecord))
        grs.taskId = grsRecord.id
    }

    override suspend fun findBy(id: Long): GroupsRelatedScams? =
        withMeasurement("Found grs by id", logger = log, constraintInMs = 100) {
            (findFirst(entity = taskRegistry) fetchFields {
                allFields
            } where {
                this.id `=` id
            })?.toDto()
        }

    override suspend fun findRecordBy(recordId: Long, statuses: List<String>): GroupsRelatedScams? =
        withMeasurement(message = "Find grs record by id and statuses", logger = log) {
            (findFirst(entity = taskRegistry, batch = false) fetchFields {
                allFields
            } where {
                id `=` recordId
                status `in` statuses
            })?.toDto()
        }

    override suspend fun findRecordsBy(recordIds: List<Long>): List<GroupsRelatedScams> =
        withMeasurement(message = "Find grs records by ids", logger = log) {
            (findAll(entity = taskRegistry, batch = false) fetchFields {
                allFields
            } where {
                id `in` recordIds
            }).map { it.toDto() }
        }

    override suspend fun findStatusByParticipantIdAndSchemeId(participantId: Long, schemeId: Long): String? =
        withMeasurement(message = "Find status record by participantId and schemeId", logger = log) {
            (findFirst(entity = taskRegistry, batch = false) fetchFields {
                listOf(status)
            } where {
                this.participantId `=` participantId
                this.schemeId `=` schemeId
                this.status `!=` DELETED.status.inlined
            })?.status
        }


    override suspend fun findTaskInfosByParticipantIdsAndSchemeId(
        participantIds: List<Long>,
        schemeId: Long
    ): Map<Long, TaskInfoDto> =
        withMeasurement(message = "Find task infos by participantIds and schemeId", logger = log) {
            (findAll(entity = taskRegistry, batch = false) fetchFields {
                listOf(participantId, id, status, initiator, executor)
            } where {
                this.participantId `in` participantIds
                this.schemeId `=` schemeId
                this.status `!=` DELETED.status.inlined
            }).associate { record ->
                record.participantId to TaskInfoDto(
                    participantId = record.participantId,
                    taskId = record.id,
                    status = record.status,
                    initiator = record.initiator,
                    executor = record.executor
                )
            }
        }

    override suspend fun merge(grs: GroupsRelatedScams) {
        asyncPersister.merge(listOf(grs.toEntity()))
    }

    override suspend fun merge(records: List<GroupsRelatedScams>) {
        asyncPersister.merge(records.map { it.toEntity() })
    }
}package ru.sber.poirot.grs.trace.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.metamodel.fraudScheme
import ru.sber.poirot.engine.metamodel.fraudTrace
import ru.sber.poirot.engine.metamodel.fraudTraceEditor
import ru.sber.poirot.engine.metamodel.fraudTraceMapping
import ru.sber.poirot.engine.model.api.grs.FraudTrace
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.TRACE_NOT_FOUND
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.grs.scheme.dto.SchemeDto
import ru.sber.poirot.utils.withMeasurement
import ru.sber.utils.logger

@Repository
class TraceFetcherImpl : TraceFetcher {
    private val log = logger()

    override suspend fun fetchById(id: Long): FraudTrace =
        withMeasurement(message = "Fetch trace by id", logger = log) {
            (findFirst(fraudTrace, batch = false) fetchFields {
                allFields
            } where {
                fraudTrace.id `=` id
            }) ?: throw FrontException(TRACE_NOT_FOUND.description.format(id))
        }

    override suspend fun fetchTraceMappingVersion(traceId: Long, schemeId: Long): Long =
        withMeasurement(message = "Fetch trace version by id", logger = log) {
            (findFirst(entity = fraudTraceMapping, batch = false) fetchFields {
                listOf(version)
            } where {
                fraudTraceMapping.trace.id `=` traceId
                fraudTraceMapping.schemeId `=` schemeId
            })?.version ?: throw FrontException(TRACE_NOT_FOUND.description.format(traceId))
        }

    override suspend fun fetchByIds(ids: List<Long>): List<FraudTrace> =
        withMeasurement(message = "Fetch traces by ids", logger = log) {
            findAll(fraudTrace, batch = true) fetchFields {
                allFields
            } where {
                fraudTrace.id `in` ids
            }
        }

    override suspend fun fetchByTraceValue(traceValue: String): List<SchemeDto> =
        withMeasurement(message = "Fetch schemes by traceValue", logger = log) {
            findAll(fields = with(fraudScheme) { allFields }, batch = false) where {
                fraudScheme.tracesMapping.trace.traceValue `=` traceValue
            } convertTo {
                SchemeDto(
                    id = nextField(),
                    name = nextField(),
                    description = nextField(),
                    curator = nextField(),
                    manager = nextField(),
                    supervision = nextField(),
                    status = nextField(),
                    reasonReturn = nextField(),
                    createdAt = nextField(),
                    updatedAt = nextField()
                )
            }
        }

    override suspend fun fetchSchemeIdsByTraceId(id: Long): List<Long> =
        withMeasurement(message = "Fetch schemes ids by trace id", logger = log) {
            (findAll(fraudTraceMapping, batch = false) fetchFields {
                listOf(fraudTraceMapping.trace.id, schemeId)
            } where {
                fraudTraceMapping.trace.id `=` id
            }).map { it.schemeId }
        }

    override suspend fun fetchTraceMappingId(traceId: Long, schemeId: Long): Long? =
        withMeasurement(message = "Fetch trace mapping id", logger = log) {
            (findFirst(fraudTraceMapping, batch = false) fetchFields {
                listOf(fraudTraceMapping.id)
            } where {
                fraudTraceMapping.trace.id `=` traceId and
                        fraudTraceMapping.schemeId `=` schemeId
            })?.id
        }

    override suspend fun fetchTraceMappingIds(traceIds: List<Long>, schemeId: Long): List<Long> =
        withMeasurement(message = "Fetch mapping ids by trace ids and scheme id", logger = log) {
            (findAll(fraudTraceMapping, batch = true) fetchFields {
                listOf(fraudTraceMapping.id)
            } where {
                fraudTraceMapping.trace.id `in` traceIds and
                        fraudTraceMapping.schemeId `=` schemeId
            }).map { it.id }
        }

    override suspend fun fetchTraceEditorBy(traceIds: List<Long>, schemeId: Long): List<Long> =
        withMeasurement(message = "Fetch trace editor records by trace ids and scheme id", logger = log) {
            (findAll(fraudTraceEditor, batch = true) fetchFields {
                listOf(fraudTraceEditor.id)
            } where {
                fraudTraceEditor.traceId `in` traceIds and
                        fraudTraceEditor.schemeId `=` schemeId
            }).map { it.id }
        }

    override suspend fun existByTraceValue(traceValue: String): Long? =
        withMeasurement(message = "Fetch by trace value", logger = log) {
            (findFirst(fraudTrace, batch = false) fetchFields {
                listOf(fraudTrace.id)
            } where {
                fraudTrace.traceValue `=` traceValue
            })?.id
        }
}
package ru.sber.poirot.grs.unified.common.dao

import org.springframework.stereotype.Repository
import ru.sber.poirot.common.UnifiedRecord
import ru.sber.poirot.engine.dsl.Filter
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.inlined
import ru.sber.poirot.engine.metamodel.fraudScheme
import ru.sber.poirot.engine.metamodel.taskRegistry
import ru.sber.poirot.grs.shared.model.SchemaStatus.APPROVAL
import ru.sber.poirot.utils.withMeasurement
import ru.sber.utils.logger

@Repository
class DslUnifiedRecordsDao : UnifiedRecordsDao {
    private val log = logger()

    override suspend fun findUnifiedDisRecords(filter: Filter): List<UnifiedRecord> =
        withMeasurement(message = "Found unified dis records", logger = log, constraintInMs = 100) {
            (findAll(
                entity = taskRegistry,
                batch = false,
            ) fetchFields {
                listOf(id, creationDateTime, inn, status)
            } where {
                filter
            }).map { record ->
                UnifiedRecord(
                    date = record.creationDateTime,
                    name = null,
                    appId = null,
                    inn = record.inn,
                    status = record.status,
                    id = record.id.toString()
                )
            }
        }

    override suspend fun findUnifiedSchemeRecords(login: String): List<UnifiedRecord> =
        withMeasurement(message = "Found unified scheme records", logger = log, constraintInMs = 100) {
            (findAll(
                entity = fraudScheme,
                batch = false,
            ) fetchFields {
                listOf(id, ctlValidform, name, status)
            } where {
                manager `=` login.inlined
                status `=` APPROVAL.status.inlined
            }).map { record ->
                UnifiedRecord(
                    date = record.ctlValidform,
                    name = record.name,
                    appId = null,
                    inn = null,
                    status = record.status,
                    id = record.id.toString()
                )
            }
        }
}package ru.sber.poirot.grs.versioning.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.filters.SqlFilter.Companion.emptyFilter
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.metamodel.fraudParticipantEditor
import ru.sber.poirot.engine.metamodel.fraudParticipantMapping
import ru.sber.poirot.engine.model.api.grs.FraudParticipantEditor
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.PARTICIPANT_NOT_FOUND
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.utils.withMeasurement
import ru.sber.poirot.grs.versioning.dto.EditorDto
import ru.sber.utils.logger

@Repository
class ParticipantEditorFetcherImpl : EditorFetcher<ru.sber.poirot.engine.model.full.grs.FraudParticipantEditor> {
    private val log = logger()

    override suspend fun findByEntityIdAndFio(entityId: Long, fio: String, schemeId: Long?): EditorDto? =
        withMeasurement(message = "Fetch participant editor by entityId and fio", logger = log) {
            (findFirst(entity = fraudParticipantEditor, batch = false) fetchFields {
                listOf(id, this.schemeId, participantId, editorFio, startedEditingAt)
            } where {
                participantId `=` entityId
                this.schemeId `=` schemeId!!
                editorFio `=` fio
            })?.toDto()
        }

    override suspend fun findAll(): List<EditorDto> =
        withMeasurement(message = "Fetch participant editors", logger = log) {
            (findAll(entity = fraudParticipantEditor, batch = false) fetchFields {
                allFields
            } where {
                emptyFilter()
            }).map { it.toDto() }
        }

    override suspend fun findVersionById(entityId: Long, schemeId: Long?): Long =
        withMeasurement(message = "Fetch participant version", logger = log) {
            (findFirst(entity = fraudParticipantMapping, batch = false) fetchFields {
                listOf(version)
            } where {
                fraudParticipantMapping.participant.id `=` entityId
                fraudParticipantMapping.schemeId `=` schemeId!!
            })?.version ?: throw FrontException(PARTICIPANT_NOT_FOUND.description.format(entityId))
        }

    private fun FraudParticipantEditor.toDto(): EditorDto {
        return EditorDto(
            id = this.id,
            schemeId = this.schemeId,
            entityId = this.participantId,
            editorFio = this.editorFio,
            startedEditingAt = this.startedEditingAt
        )
    }
}package ru.sber.poirot.grs.versioning.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.filters.SqlFilter.Companion.emptyFilter
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.metamodel.fraudTraceEditor
import ru.sber.poirot.engine.metamodel.fraudTraceMapping
import ru.sber.poirot.engine.model.api.grs.FraudTraceEditor
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.TRACE_NOT_FOUND
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.utils.withMeasurement
import ru.sber.poirot.grs.versioning.dto.EditorDto
import ru.sber.utils.logger

@Repository
class TraceEditorFetcherImpl : EditorFetcher<ru.sber.poirot.engine.model.full.grs.FraudTraceEditor> {
    private val log = logger()

    override suspend fun findByEntityIdAndFio(entityId: Long, fio: String, schemeId: Long?): EditorDto? =
        withMeasurement(message = "Fetch trace editor by entityId and fio", logger = log) {
            (findFirst(entity = fraudTraceEditor, batch = false) fetchFields {
                listOf(id, this.schemeId, traceId, editorFio, startedEditingAt)
            } where {
                traceId `=` entityId
                this.schemeId `=` schemeId!!
                editorFio `=` fio
            })?.toDto()
        }

    override suspend fun findAll(): List<EditorDto> =
        withMeasurement(message = "Fetch trace editors", logger = log) {
            (findAll(entity = fraudTraceEditor, batch = false) fetchFields {
                allFields
            } where {
                emptyFilter()
            }).map { it.toDto() }
        }

    override suspend fun findVersionById(entityId: Long, schemeId: Long?): Long =
        withMeasurement(message = "Fetch trace version", logger = log) {
            (findFirst(entity = fraudTraceMapping, batch = false) fetchFields {
                listOf(version)
            } where {
                fraudTraceMapping.trace.id `=` entityId
                fraudTraceMapping.schemeId `=` schemeId!!
            })?.version ?: throw FrontException(TRACE_NOT_FOUND.description.format(entityId))
        }

    private fun FraudTraceEditor.toDto(): EditorDto {
        return EditorDto(
            id = this.id,
            schemeId = this.schemeId,
            entityId = this.traceId,
            editorFio = this.editorFio,
            startedEditingAt = this.startedEditingAt
        )
    }
}package ru.sber.poirot.grs.versioning.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.filters.emptyFilter
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.metamodel.fraudScheme
import ru.sber.poirot.engine.metamodel.fraudSchemeEditor
import ru.sber.poirot.engine.model.api.grs.FraudSchemeEditor
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.SCHEME_NOT_FOUND
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.utils.withMeasurement
import ru.sber.poirot.grs.versioning.dto.EditorDto
import ru.sber.utils.logger

@Repository
class SchemaEditorFetcherImpl : EditorFetcher<ru.sber.poirot.engine.model.full.grs.FraudSchemeEditor> {
    private val log = logger()

    override suspend fun findByEntityIdAndFio(entityId: Long, fio: String, schemeId: Long?): EditorDto? =
        withMeasurement(message = "Fetch scheme editor by entityId and fio", logger = log) {
            (findFirst(entity = fraudSchemeEditor, batch = false) fetchFields {
                listOf(id, this.schemeId, editorFio, startedEditingAt)
            } where {
                this.schemeId `=` entityId
                editorFio `=` fio
            })?.toDto()
        }


    override suspend fun findAll() =
        withMeasurement(message = "Fetch scheme editors", logger = log) {
            (findAll(entity = fraudSchemeEditor, batch = false) fetchFields {
                allFields
            } where {
                emptyFilter()
            }).map { it.toDto() }
        }

    override suspend fun findVersionById(entityId: Long, schemeId: Long?): Long =
        withMeasurement(message = "Fetch scheme version", logger = log) {
            (findFirst(entity = fraudScheme, batch = false) fetchFields {
                listOf(fraudScheme.version)
            } where {
                fraudScheme.id `=` entityId
            })?.version ?: throw FrontException(SCHEME_NOT_FOUND.description.format(entityId))
        }

    private fun FraudSchemeEditor.toDto(): EditorDto {
        return EditorDto(
            id = this.id,
            entityId = this.schemeId,
            editorFio = this.editorFio,
            startedEditingAt = this.startedEditingAt
        )
    }
}
