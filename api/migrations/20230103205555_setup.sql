-- Setup copied from https://github.com/launchbadge/realworld-axum-sqlx/blob/main/migrations/1_setup.sql

-- This extension gives us `uuid_generate_v1mc()` which generates UUIDs that cluster better than `gen_random_uuid()`
-- while still being difficult to predict and enumerate.
-- Also, while unlikely, `gen_random_uuid()` can in theory produce collisions which can trigger spurious errors on
-- insertion, whereas it's much less likely with `uuid_generate_v1mc()`.
create extension if not exists "uuid-ossp";

-- We try to ensure every table has `created_at` and `updated_at` columns, which can help immensely with debugging
-- and auditing.
--
-- While `created_at` can just be `default now()`, setting `updated_at` on update requires a trigger which
-- is a lot of boilerplate. These two functions save us from writing that every time as instead we can just do
--
-- select trigger_updated_at('<table name>');
--
-- after a `CREATE TABLE`.
create or replace function set_updated_at()
    returns trigger as
$$
begin
    NEW.updated_at = now();
    return NEW;
end;
$$ language plpgsql;

create or replace function trigger_updated_at(tablename regclass)
    returns void as
$$
begin
    execute format('CREATE TRIGGER set_updated_at
        BEFORE UPDATE
        ON %s
        FOR EACH ROW
        WHEN (OLD is distinct from NEW)
    EXECUTE FUNCTION set_updated_at();', tablename);
end;
$$ language plpgsql;

CREATE TYPE contribution_change_type AS ENUM (
	'creation',
	'amendment',
	'modification',
	'synthesis',
	'Unknown',
	'deleted');

CREATE TYPE contribution_data_type AS ENUM (
	'composition',
	'folder',
	'ehr',
	'system',
	'other');

CREATE TYPE contribution_state AS ENUM (
	'complete',
	'incomplete',
	'deleted');

CREATE TYPE entry_type AS ENUM (
	'section',
	'care_entry',
	'admin',
	'proxy');

CREATE TYPE party_ref_id_type AS ENUM (
	'generic_id',
	'object_version_id',
	'hier_object_id',
	'undefined');

CREATE TYPE party_type AS ENUM (
	'party_identified',
	'party_self',
	'party_related');

CREATE TYPE code_phrase AS (
	terminology_id_value text,
	code_string text
);

CREATE TYPE dv_coded_text AS (
	value text,
	defining_code code_phrase,
	formatting text,
	"language" code_phrase,
	"encoding" code_phrase,
	term_mapping text
);
