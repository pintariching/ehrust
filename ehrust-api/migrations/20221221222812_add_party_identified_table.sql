create table party_identified (
    id uuid primary key not null default uuid_generate_v4(),
    "name" text,
    -- optional party ref attributes
    party_ref_value text,
    party_ref_scheme text,
    party_ref_namespace text,
    party_ref_type text,
    "party_type" party_type not null default 'party_identified'::party_type,
    relationship dv_coded_text,
    object_id_type "party_ref_id_type" null default 'generic_id'::party_ref_id_type,
    "namespace" uuid not null
);

create index ehr_subject_id_index on party_identified using btree (jsonb_extract_path_text((js_party_ref(party_ref_value, party_ref_scheme, party_ref_namespace, party_ref_type))::jsonb, variadic array['id'::text, 'value'::text]), namespace);
create index party_identified_namespace_value_idx on party_identified using btree (party_ref_namespace, party_ref_value, "namespace");
create index party_identified_party_ref_idx on party_identified using btree (party_ref_namespace, party_ref_scheme, party_ref_value, "namespace");
create index party_identified_party_type_idx on party_identified using btree (party_type, "name", "namespace");
