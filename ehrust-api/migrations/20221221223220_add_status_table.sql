create table status (
    id uuid primary key not null default uuid_generate_v4(),
    ehr_id uuid references ehr(id) on delete cascade,
    is_queryable boolean default true,
    is_modifiable boolean default true,
    party uuid not null references party_identified(id),  -- subject (e.g. patient)
    other_details jsonb,
    sys_transaction timestamp not null,
    sys_period tstzrange not null, -- temporal table
    has_audit uuid not null references audit_details(id) on delete cascade,
    attestation_ref uuid references attestation_ref("ref") on delete cascade,
    in_contribution uuid not null references contribution(id) on delete cascade,
    archetype_node_id text not null default 'openEHR-EHR-EHR_STATUS.generic.v1'::text,
    "name" dv_coded_text not null default row('ehr status'::text, null::code_phrase, null::text, null::code_phrase, null::code_phrase, null)::dv_coded_text,
	"namespace" uuid not null,
    constraint status_ehr_id_key unique (ehr_id, "namespace")
);

create index status_party_idx on status using btree (party, "namespace");
comment on table status is 'specifies an ehr modality and ownership (patient)';

create trigger versioning_trigger before insert
or delete
or update on
status for each row execute function versioning('sys_period', 'status_history', 'true');
