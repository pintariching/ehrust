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

-- Finally, this is a text collation that sorts text case-insensitively, useful for `UNIQUE` indexes
-- over things like usernames and emails, without needing to remember to do case-conversion.
create collation case_insensitive (provider = icu, locale = 'und-u-ks-level2', deterministic = false);


-- ensure INTERVAL is ISO8601 encoded
alter database ehrust set intervalstyle = 'iso_8601';

-- load the temporal_tables PLPG/SQL functions to emulate the coded extension
-- original source: https://github.com/nearform/temporal_tables/blob/master/versioning_function.sql
CREATE OR REPLACE FUNCTION versioning()
RETURNS TRIGGER AS $$
DECLARE
    sys_period text;
    history_table text;
    manipulate jsonb;
    ignore_unchanged_values bool;
    commonColumns text[];
    time_stamp_to_use timestamptz := current_timestamp;
    range_lower timestamptz;
    transaction_info txid_snapshot;
    existing_range tstzrange;
    holder record;
    holder2 record;
    pg_version integer;
BEGIN
  -- version 0.4.0

IF TG_WHEN != 'BEFORE' OR TG_LEVEL != 'ROW' THEN
    RAISE TRIGGER_PROTOCOL_VIOLATED USING
    MESSAGE = 'function "versioning" must be fired BEFORE ROW';
END IF;

IF TG_OP != 'INSERT' AND TG_OP != 'UPDATE' AND TG_OP != 'DELETE' THEN
    RAISE TRIGGER_PROTOCOL_VIOLATED USING
    MESSAGE = 'function "versioning" must be fired for INSERT or UPDATE or DELETE';
END IF;

IF TG_NARGS not in (3,4) THEN
    RAISE INVALID_PARAMETER_VALUE USING
    MESSAGE = 'wrong number of parameters for function "versioning"',
    HINT = 'expected 3 or 4 parameters but got ' || TG_NARGS;
END IF;

    sys_period := TG_ARGV[0];
    history_table := TG_ARGV[1];
    ignore_unchanged_values := TG_ARGV[3];

IF ignore_unchanged_values AND TG_OP = 'UPDATE' AND NEW IS NOT DISTINCT FROM OLD THEN
    RETURN OLD;
END IF;

-- check if sys_period exists on original table
SELECT atttypid, attndims INTO holder FROM pg_attribute WHERE attrelid = TG_RELID AND attname = sys_period AND NOT attisdropped;
IF NOT FOUND THEN
    RAISE 'column "%" of relation "%" does not exist', sys_period, TG_TABLE_NAME USING
    ERRCODE = 'undefined_column';
END IF;

IF holder.atttypid != to_regtype('tstzrange') THEN
    IF holder.attndims > 0 THEN
        RAISE 'system period column "%" of relation "%" is not a range but an array', sys_period, TG_TABLE_NAME USING
        ERRCODE = 'datatype_mismatch';
    END IF;

    SELECT rngsubtype INTO holder2 FROM pg_range WHERE rngtypid = holder.atttypid;
    IF FOUND THEN
        RAISE 'system period column "%" of relation "%" is not a range of timestamp with timezone but of type %', sys_period, TG_TABLE_NAME, format_type(holder2.rngsubtype, null) USING
        ERRCODE = 'datatype_mismatch';
    END IF;

    RAISE 'system period column "%" of relation "%" is not a range but type %', sys_period, TG_TABLE_NAME, format_type(holder.atttypid, null) USING
    ERRCODE = 'datatype_mismatch';
END IF;

IF TG_OP = 'UPDATE' OR TG_OP = 'DELETE' THEN
    -- Ignore rows already modified in this transaction
    transaction_info := txid_current_snapshot();
    IF OLD.xmin::text >= (txid_snapshot_xmin(transaction_info) % (2^32)::bigint)::text
    AND OLD.xmin::text <= (txid_snapshot_xmax(transaction_info) % (2^32)::bigint)::text THEN
    IF TG_OP = 'DELETE' THEN
    RETURN OLD;
END IF;

RETURN NEW;
END IF;

SELECT current_setting('server_version_num')::integer
INTO pg_version;

-- to support postgres < 9.6
IF pg_version < 90600 THEN
    -- check if history table exits
    IF to_regclass(history_table::cstring) IS NULL THEN
        RAISE 'relation "%" does not exist', history_table;
    END IF;
ELSE
    IF to_regclass(history_table) IS NULL THEN
        RAISE 'relation "%" does not exist', history_table;
    END IF;
END IF;

    -- check if history table has sys_period
    IF NOT EXISTS(SELECT * FROM pg_attribute WHERE attrelid = history_table::regclass AND attname = sys_period AND NOT attisdropped) THEN
        RAISE 'history relation "%" does not contain system period column "%"', history_table, sys_period USING
        HINT = 'history relation must contain system period column with the same name and data type as the versioned one';
END IF;

EXECUTE format('SELECT $1.%I', sys_period) USING OLD INTO existing_range;

IF existing_range IS NULL THEN
    RAISE 'system period column "%" of relation "%" must not be null', sys_period, TG_TABLE_NAME USING
    ERRCODE = 'null_value_not_allowed';
END IF;

IF isempty(existing_range) OR NOT upper_inf(existing_range) THEN
    RAISE 'system period column "%" of relation "%" contains invalid value', sys_period, TG_TABLE_NAME USING
    ERRCODE = 'data_exception',
    DETAIL = 'valid ranges must be non-empty and unbounded on the high side';
END IF;

IF TG_ARGV[2] = 'true' THEN
    -- mitigate update conflicts
    range_lower := lower(existing_range);
    IF range_lower >= time_stamp_to_use THEN
        time_stamp_to_use := range_lower + interval '1 microseconds';
    END IF;
END IF;

WITH history AS
    (SELECT attname, atttypid
    FROM pg_attribute
    WHERE attrelid = history_table::regclass
    AND attnum > 0
    AND NOT attisdropped),
    main AS
    (SELECT attname, atttypid
FROM pg_attribute
WHERE attrelid = TG_RELID
AND attnum > 0
AND NOT attisdropped)
SELECT
    history.attname AS history_name,
    main.attname AS main_name,
    history.atttypid AS history_type,
    main.atttypid AS main_type
INTO holder
FROM history
    INNER JOIN main
    ON history.attname = main.attname
WHERE
    history.atttypid != main.atttypid;

IF FOUND THEN
    RAISE 'column "%" of relation "%" is of type % but column "%" of history relation "%" is of type %',
        holder.main_name, TG_TABLE_NAME, format_type(holder.main_type, null), holder.history_name, history_table, format_type(holder.history_type, null)
    USING ERRCODE = 'datatype_mismatch';
END IF;

WITH history AS
    (SELECT attname
        FROM pg_attribute
        WHERE attrelid = history_table::regclass
        AND attnum > 0
        AND NOT attisdropped),
        main AS
            (SELECT attname
            FROM pg_attribute
            WHERE attrelid = TG_RELID
            AND attnum > 0
            AND NOT attisdropped)
            SELECT array_agg(quote_ident(history.attname)) INTO commonColumns
    FROM history
    INNER JOIN main
    ON history.attname = main.attname
    AND history.attname != sys_period;

EXECUTE ('INSERT INTO ' ||
    history_table ||
    '(' ||
    array_to_string(commonColumns , ',') ||
    ',' ||
    quote_ident(sys_period) ||
    ') VALUES ($1.' ||
    array_to_string(commonColumns, ',$1.') ||
    ',tstzrange($2, $3, ''[)''))')
    USING OLD, range_lower, time_stamp_to_use;
END IF;

IF TG_OP = 'UPDATE' OR TG_OP = 'INSERT' THEN
    manipulate := jsonb_set('{}'::jsonb, ('{' || sys_period || '}')::text[], to_jsonb(tstzrange(time_stamp_to_use, null, '[)')));

RETURN jsonb_populate_record(NEW, manipulate);
END IF;

RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION tr_function_delete_folder_item()
    RETURNS trigger
    LANGUAGE plpgsql
AS $function$BEGIN
DELETE FROM object_ref
WHERE object_ref.id=OLD.object_ref_id AND
    object_ref.in_contribution= OLD.in_contribution;
    RETURN OLD;
END;
$function$
;

COMMENT ON FUNCTION tr_function_delete_folder_item() IS 'fires after deletion of folder_items when the corresponding Object_ref  needs to be deleted.';

CREATE OR REPLACE FUNCTION js_party_ref(text, text, text, text)
    RETURNS json
    LANGUAGE plpgsql
    IMMUTABLE
AS $function$
DECLARE
    id_value ALIAS FOR $1;
    id_scheme ALIAS FOR $2;
    namespace ALIAS FOR $3;
    party_type ALIAS FOR $4;
BEGIN
    IF (id_value IS NULL AND id_scheme IS NULL AND namespace IS NULL AND party_type IS NULL) THEN
        RETURN NULL;
    ELSE
        RETURN
            json_build_object(
                '_type', 'PARTY_REF',
                'id',
                json_build_object(
                        '_type', 'GENERIC_ID',
                        'value', id_value,
                        'scheme', id_scheme
                    ),
                'namespace', namespace,
                'type', party_type
            );
    END IF;
END
$function$
;
