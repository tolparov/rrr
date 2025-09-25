-- ================================
-- Индексы для схемы grs
-- ================================

-- fraud_participant
create index if not exists idx_fraud_participant_inn 
    on grs.fraud_participant(inn);

-- fraud_participant_mapping
create index if not exists idx_fraud_participant_mapping_participant_scheme 
    on grs.fraud_participant_mapping(participant_id, scheme_id);

create index if not exists idx_fraud_participant_mapping_scheme 
    on grs.fraud_participant_mapping(scheme_id);

-- fraud_trace_mapping
create index if not exists idx_fraud_trace_mapping_scheme 
    on grs.fraud_trace_mapping(scheme_id);

create index if not exists idx_fraud_trace_mapping_trace_scheme 
    on grs.fraud_trace_mapping(trace_id, scheme_id);

-- fraud_tag_mapping
create index if not exists idx_fraud_tag_mapping_scheme 
    on grs.fraud_tag_mapping(scheme_id);

-- fraud_scheme_editor
create index if not exists idx_fraud_scheme_editor_scheme 
    on grs.fraud_scheme_editor(scheme_id);

-- fraud_participant_editor
create index if not exists idx_fraud_participant_editor_scheme 
    on grs.fraud_participant_editor(scheme_id);

-- fraud_trace_editor
create index if not exists idx_fraud_trace_editor_scheme 
    on grs.fraud_trace_editor(scheme_id);

-- task_registry
create index if not exists idx_task_registry_participant_scheme 
    on grs.task_registry(participant_id, scheme_id);

create index if not exists idx_task_registry_scheme 
    on grs.task_registry(scheme_id);
