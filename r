CREATE TABLE IF NOT EXISTS grs.fraud_scheme (
    id BIGINT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    curator VARCHAR(255) NOT NULL,
    manager VARCHAR(255),
    supervision BOOLEAN,
    status VARCHAR(50) NOT NULL,
    reason_return VARCHAR(1000),
    ctl_validform TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    version BIGINT NOT NULL DEFAULT 0
);

create sequence if not exists grs.fraud_scheme_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_participant (
    id BIGINT PRIMARY KEY,
    is_fl BOOLEAN NOT NULL,
    inn VARCHAR(12),
    ogrn VARCHAR(15),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    second_name VARCHAR(255),
    region VARCHAR(255),
    birth_date TIMESTAMP(0),
    ctl_validform TIMESTAMP NOT NULL
);

create sequence if not exists grs.fraud_participant_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_participant_mapping (
    id BIGINT PRIMARY KEY,
    participant_id BIGINT NOT NULL,
    scheme_id BIGINT NOT NULL,
    role VARCHAR(255),
    comment VARCHAR(1000),
    similarity_criteria varchar(255),
    version BIGINT NOT NULL DEFAULT 0
);

create sequence if not exists grs.fraud_participant_mapping_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_trace (
    id BIGINT PRIMARY KEY,
    trace_type VARCHAR(50) NOT NULL,
    trace_value VARCHAR(255) NOT NULL UNIQUE,
    ctl_validform TIMESTAMP NOT NULL
);

create sequence if not exists grs.fraud_trace_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_trace_mapping (
    id BIGINT PRIMARY KEY,
    trace_id BIGINT NOT NULL,
    scheme_id BIGINT NOT NULL,
    comment VARCHAR(1000),
    version BIGINT NOT NULL DEFAULT 0
);

create sequence if not exists grs.fraud_trace_mapping_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_tag (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

create sequence if not exists grs.fraud_tag_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_tag_mapping (
    id BIGSERIAL PRIMARY KEY,
    scheme_id BIGINT NOT NULL,
    tag_id BIGINT NOT NULL
);

create sequence if not exists grs.fraud_tag_mapping_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_scheme_editor (
    id BIGSERIAL PRIMARY KEY,
    scheme_id BIGINT NOT NULL,
    editor_fio VARCHAR(255) NOT NULL,
    started_editing_at TIMESTAMP NOT NULL
);

create sequence if not exists grs.fraud_scheme_editor_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_participant_editor (
    id BIGSERIAL PRIMARY KEY,
    participant_id BIGINT NOT NULL,
    scheme_id BIGINT NOT NULL,
    editor_fio VARCHAR(255) NOT NULL,
    started_editing_at TIMESTAMP NOT NULL
);

create sequence if not exists grs.fraud_participant_editor_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.fraud_trace_editor (
    id BIGSERIAL PRIMARY KEY,
    trace_id BIGINT NOT NULL,
    scheme_id BIGINT NOT NULL,
    editor_fio VARCHAR(255) NOT NULL,
    started_editing_at TIMESTAMP NOT NULL
);

create sequence if not exists grs.fraud_trace_editor_seq increment 100 start 1;

CREATE TABLE IF NOT EXISTS grs.task_registry (
    id BIGSERIAL PRIMARY KEY,
    participant_id BIGINT NOT NULL,
    scheme_id BIGINT NOT NULL,
    creation_date_time TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,
    changed TIMESTAMP,
    date_approval TIMESTAMP,
    approver VARCHAR(50),
    initiator VARCHAR(50) NOT NULL,
    decision VARCHAR(1000),
    executor VARCHAR(100),
    inn VARCHAR(12)
);

create sequence if not exists grs.task_registry_seq increment 100 start 1;
package ru.sber.poirot.grs.participant.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.Filter
import ru.sber.poirot.engine.dsl.convertTo
import ru.sber.poirot.engine.dsl.findAll
import ru.sber.poirot.engine.dsl.findFirst
import ru.sber.poirot.engine.metamodel.fraudParticipant
import ru.sber.poirot.engine.metamodel.fraudParticipantEditor
import ru.sber.poirot.engine.metamodel.fraudParticipantMapping
import ru.sber.poirot.engine.metamodel.fraudScheme
import ru.sber.poirot.engine.model.api.grs.FraudParticipant
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.PARTICIPANT_NOT_FOUND
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.grs.scheme.dto.SchemeDto
import ru.sber.poirot.utils.withMeasurement
import ru.sber.utils.logger

@Repository
class ParticipantFetcherImpl : ParticipantFetcher {
    private val log = logger()

    override suspend fun fetchById(id: Long): FraudParticipant =
        withMeasurement(message = "Fetch participant by id", logger = log) {
            (findFirst(fraudParticipant, batch = false) fetchFields {
                allFields
            } where {
                fraudParticipant.id `=` id
            }) ?: throw FrontException(PARTICIPANT_NOT_FOUND.description.format(id))
        }

    override suspend fun fetchParticipantMappingVersion(participantId: Long, schemeId: Long): Long =
        withMeasurement(message = "Fetch participant version by id", logger = log) {
            (findFirst(entity = fraudParticipantMapping, batch = false) fetchFields {
                listOf(version)
            } where {
                fraudParticipantMapping.participant.id `=` participantId
                fraudParticipantMapping.schemeId `=` schemeId
            })?.version ?: throw FrontException(PARTICIPANT_NOT_FOUND.description.format(participantId))
        }

    override suspend fun fetchByIds(ids: List<Long>): List<FraudParticipant> =
        withMeasurement(message = "Fetch participants by ids", logger = log) {
            findAll(fraudParticipant, batch = true) fetchFields {
                allFields
            } where {
                fraudParticipant.id `in` ids
            }
        }

    override suspend fun fetchSchemesByInn(inn: String): List<SchemeDto> =
        withMeasurement(message = "Fetch schemes by inn", logger = log) {
            findAll(fields = with(fraudScheme) { allFields }, batch = false) where {
                fraudScheme.participantsMapping.participant.inn `=` inn
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

    override suspend fun fetchSchemeIdsByParticipantId(id: Long): List<Long> =
        withMeasurement(message = "Fetch schemes ids by participant id", logger = log) {
            (findAll(fraudParticipantMapping, batch = false) fetchFields {
                listOf(fraudParticipantMapping.participant.id, schemeId)
            } where {
                fraudParticipantMapping.participant.id `=` id
            }).map { it.schemeId }
        }

    override suspend fun fetchParticipantMappingId(participantId: Long, schemeId: Long): Long? =
        withMeasurement(message = "Fetch schemes ids by participant id", logger = log) {
            (findFirst(fraudParticipantMapping, batch = false) fetchFields {
                listOf(fraudParticipantMapping.id)
            } where {
                fraudParticipantMapping.participant.id `=` participantId and
                        fraudParticipantMapping.schemeId `=` schemeId
            })?.id
        }

    override suspend fun fetchParticipantMappingIds(participantIds: List<Long>, schemeId: Long): List<Long> =
        withMeasurement(message = "Fetch mapping ids by participant ids and scheme id", logger = log) {
            (findAll(fraudParticipantMapping, batch = true) fetchFields {
                listOf(fraudParticipantMapping.id)
            } where {
                fraudParticipantMapping.participant.id `in` participantIds and
                        fraudParticipantMapping.schemeId `=` schemeId
            }).map { it.id }
        }

    override suspend fun fetchParticipantEditorBy(participantIds: List<Long>, schemeId: Long): List<Long> =
        withMeasurement(message = "Fetch participant editor records by participant ids and scheme id", logger = log) {
            (findAll(fraudParticipantEditor, batch = true) fetchFields {
                listOf(fraudParticipantEditor.id)
            } where {
                fraudParticipantEditor.participantId `in` participantIds and
                fraudParticipantEditor.schemeId `=` schemeId
            }).map { it.id }
        }


    override suspend fun existBy(filter: Filter): Long? =
        withMeasurement(message = "Find first participant by filter", logger = log) {
            (findFirst(fraudParticipant, batch = false) fetchFields {
                listOf(fraudParticipant.id)
            } where {
                filter
            })?.id
        }
}package ru.sber.poirot.grs.scheme.fetch

import org.springframework.stereotype.Repository
import ru.sber.poirot.engine.dsl.*
import ru.sber.poirot.engine.dsl.filters.SqlFilter.Companion.emptyFilter
import ru.sber.poirot.engine.metamodel.*
import ru.sber.poirot.engine.model.api.grs.FraudScheme
import ru.sber.poirot.engine.model.full.grs.FraudTag
import ru.sber.poirot.grs.shared.error.GroupsRelatedScamsErrorCode.SCHEME_NOT_FOUND
import ru.sber.poirot.exception.FrontException
import ru.sber.poirot.grs.participant.dto.ParticipantDto
import ru.sber.poirot.grs.scheme.dto.SchemeDto
import ru.sber.poirot.grs.scheme.dto.TaskInfoDto
import ru.sber.poirot.grs.shared.model.GroupsRelatedScamsStatus.DELETED
import ru.sber.poirot.grs.shared.model.toSchemeDto
import ru.sber.poirot.grs.trace.dto.TraceDto
import ru.sber.poirot.utils.withMeasurement
import ru.sber.utils.letIfNotNull
import ru.sber.utils.logger

@Repository
class SchemeFetcherImpl : SchemeFetcher {
    private val log = logger()

    override suspend fun fetchAll(): List<SchemeDto> =
        withMeasurement(message = "Fetch schemes", logger = log) {
            val schemes = (findAll(fields = with(fraudScheme) { allFields }, batch = false) where {
                emptyFilter()
            }).toSchemeDto()

            if (schemes.isEmpty()) {
                return@withMeasurement emptyList()
            }

            val schemeIds = schemes.map { it.id }
            val tagsBySchemeId = fetchTagsForSchemes(schemeIds)

            schemes.map { scheme ->
                scheme.copy(tags = tagsBySchemeId[scheme.id] ?: emptyList())
            }
        }

    override suspend fun fetchVersionById(id: Long): Long =
        withMeasurement(message = "Fetch scheme version by id", logger = log) {
            (findFirst(fraudScheme, batch = false) fetchFields {
                listOf(version)
            } where {
                (fraudScheme.id `=` id)
            })?.version ?: throw FrontException(SCHEME_NOT_FOUND.description.format(id))
        }


    override suspend fun existById(id: Long): Boolean =
        withMeasurement(message = "Exist scheme by id", logger = log) {
            existsAny(fraudScheme.id, batch = false) where {
                (fraudScheme.id `=` id)
            }
        }

    override suspend fun fetchTagMappingIdsBySchemeId(id: Long): List<Long> =
        withMeasurement(message = "Fetch tags ids by schemeId", logger = log) {
            (findAll(entity = fraudTagMapping, batch = false) fetchFields {
                listOf(fraudTagMapping.id)
            } where {
                fraudTagMapping.schemeId `=` id
            }).map { it.id }
        }


    override suspend fun fetchById(id: Long): FraudScheme =
        withMeasurement(message = "Fetch scheme by id", logger = log) {
            (findFirst(fraudScheme, batch = false) fetchFields {
                allFields
            } where {
                (fraudScheme.id `=` id)
            }) ?: throw FrontException(SCHEME_NOT_FOUND.description.format(id))
        }

    override suspend fun fetchParticipantById(schemeId: Long): List<ParticipantDto> {
        // 1. Получаем ID всех участников схемы
        val participantIds = withMeasurement("Fetch participant IDs for scheme", logger = log) {
            (findAll(fields = listOf(fraudScheme.participantsMapping.participant.id), batch = false) where {
                fraudScheme.id `=` schemeId
                fraudScheme.participantsMapping.participant.id.isNotNull()
            }).flatten().map { it as Long }
        }

        if (participantIds.isEmpty()) {
            return emptyList()
        }

        // 2. Получаем статусы и исполнителей задач для этих участников
        val tasksInfo = withMeasurement("Fetch task executor and status", logger = log) {
            (findAll(with(taskRegistry) {
                listOf(
                    taskRegistry.participantId,
                    taskRegistry.status,
                    taskRegistry.executor
                )
            }, batch = false) where {
                taskRegistry.participantId `in` participantIds
                taskRegistry.schemeId `=` schemeId
                taskRegistry.status `!=` DELETED.status.inlined
            } convertTo {
                TaskInfoDto(
                    participantId = nextField() as Long,
                    status = nextField(),
                    executor = nextField()
                )
            }).groupBy { it.participantId }
        }

        return withMeasurement("Fetch participant details", logger = log) {
            findAll(fields = with(fraudParticipant) {
                listOf(
                    fraudScheme.participantsMapping.participant.id,
                    fraudScheme.participantsMapping.participant.fL,
                    fraudScheme.participantsMapping.participant.inn,
                    fraudScheme.participantsMapping.participant.ogrn,
                    fraudScheme.participantsMapping.participant.firstName,
                    fraudScheme.participantsMapping.participant.lastName,
                    fraudScheme.participantsMapping.participant.secondName,
                    fraudScheme.participantsMapping.participant.region,
                    fraudScheme.participantsMapping.participant.birthDate,
                    fraudScheme.participantsMapping.participant.ctlValidform,
                    fraudScheme.participantsMapping.role,
                    fraudScheme.participantsMapping.comment,
                    fraudScheme.participantsMapping.similarityCriteria,
                )
            }, batch = false) where {
                fraudScheme.participantsMapping.participant.id `in` participantIds
                fraudScheme.participantsMapping.schemeId `=` schemeId
            } convertTo {
                val participantId = nextField() as Long
                val taskInfo = tasksInfo[participantId]?.firstOrNull()

                ParticipantDto(
                    id = participantId,
                    isFL = nextField(),
                    inn = nextField(),
                    ogrn = nextField(),
                    firstName = nextField(),
                    lastName = nextField(),
                    secondName = nextField(),
                    region = nextField(),
                    birthDate = nextField(),
                    status = taskInfo?.status,
                    executor = taskInfo?.executor,
                    createdAt = nextField(),
                    roles = nextField<String>().letIfNotNull{ it.split(",") } ?: emptyList(),
                    comment = nextField(),
                    similarityCriteria = nextField()
                )
            }
        }
    }

    override suspend fun fetchTraceById(schemeId: Long): List<TraceDto> {
        val traceIds = withMeasurement("Fetch trace IDs for scheme", logger = log) {
            (findAll(fields = listOf(fraudScheme.tracesMapping.trace.id), batch = false) where {
                fraudScheme.id `=` schemeId
                fraudScheme.tracesMapping.trace.id.isNotNull()
            }).flatten().map { it as Long }
        }

        if (traceIds.isEmpty()) {
            return emptyList()
        }

        return withMeasurement(message = "Fetch traces by id", logger = log) {
            findAll(fields = with(fraudTrace) {
                listOf(
                    fraudScheme.tracesMapping.trace.id,
                    fraudScheme.tracesMapping.trace.traceType,
                    fraudScheme.tracesMapping.trace.traceValue,
                    fraudScheme.tracesMapping.trace.ctlValidform,
                    fraudScheme.tracesMapping.comment
                )
            }, batch = false) where {
                fraudScheme.tracesMapping.trace.id `in` traceIds
                fraudScheme.tracesMapping.schemeId `=` schemeId
            } convertTo {
                TraceDto(
                    id = nextField(),
                    traceType = nextField(),
                    traceValue = nextField(),
                    createdAt = nextField(),
                    comment = nextField()
                )
            }
        }
    }

    override suspend fun fetchByNameIn(tagNames: List<String>): List<FraudTag> =
        withMeasurement(message = "Fetch tags", logger = log) {
            (findAll(entity = fraudTag, batch = false) fetchFields {
                allFields
            } where {
                fraudTag.name `in` tagNames
            }).map {
                FraudTag().apply {
                    id = it.id
                    name = it.name
                }
            }
        }

    override suspend fun fetchTagsForSchemes(schemeIds: List<Long>): Map<Long, List<String>> =
        (findAll(entity = fraudTagMapping, batch = false) fetchFields {
            listOf(fraudTagMapping.schemeId, fraudTagMapping.tag.name)
        } where {
            fraudTagMapping.schemeId `in` schemeIds
        }).groupBy(
            { it.schemeId },
            { it.tag.name }
        )

    override suspend fun fetchAllTags(): List<String> =
        (findAll(entity = fraudTag, batch = false) fetchFields {
            listOf(name)
        } where {
            emptyFilter()
        }).map { it.name }.toList()

}
