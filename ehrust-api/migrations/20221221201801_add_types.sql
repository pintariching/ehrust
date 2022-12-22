CREATE TYPE code_phrase AS (
	terminology_id_value text,
	code_string text
);

CREATE TYPE dv_coded_text AS (
	"value" text,
	defining_code code_phrase,
	formatting text,
	"language" code_phrase,
	"encoding" code_phrase,
	term_mapping _text
);

create type party_type as enum (
	'party_identified',
	'party_self',
	'party_related'
);

create type party_ref_id_type as enum (
	'generic_id',
	'object_version_id',
	'hier_object_id',
	'undefined'
);

create type contribution_data_type as enum (
    'composition',
    'folder',
    'ehr',
    'system',
    'other'
);

create type contribution_state as enum (
    'complete',
    'incomplete',
    'deleted'
);

create type contribution_change_type as enum (
    'creation',
    'amendment',
    'modification',
    'synthesis',
    'unknown',
    'deleted'
);

create type "entry_type" as enum (
    'section',
    'care_entry',
    'admin',
    'proxy'
);
