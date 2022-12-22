create table "entry" (
    id uuid primary key not null default uuid_generate_v4(),
    composition_id uuid references composition(id) on delete cascade,
    "sequence" int4,
    item_type "entry_type",
    template_id text,
    template_uuid uuid,
    archetype_id text,
    category dv_coded_text,
    entry jsonb,
    sys_transaction timestamp not null,
    sys_period tstzrange not null,
    rm_version text not null default '1.0.4'::text,
    "name" dv_coded_text not null default row('_DEFAULT_NAME'::text, null::code_phrase, null::text, null::code_phrase, null::code_phrase, null)::dv_coded_text,
    "namespace" uuid not null,
    constraint entry_composition_id_key unique (composition_id, "namespace")
);

create index template_entry_idx on entry using btree (template_id, "namespace");

create trigger versioning_trigger before insert
or delete
or update on
entry for each row execute function versioning('sys_period', 'entry_history', 'true');
