create table stored_query (
    reverse_domain_name varchar not null,
    semantic_id varchar not null,
    semver varchar not null default '0.0.0'::character varying,
    query_text varchar not null,
    creation_date timestamp default current_timestamp,
    "type" varchar default 'aql'::character varying,
    "namespace" uuid not null,
    constraint pk_qualified_name primary key (reverse_domain_name, semantic_id, semver),
    constraint stored_query_reverse_domain_name_check check (((reverse_domain_name)::text ~* '^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z0-9][a-z0-9-]{0,61}[a-z0-9]$'::text)),
    constraint stored_query_semantic_id_check check (((semantic_id)::text ~* '[\w|\-|_|]+'::text)),
    constraint stored_query_semver_check check (((semver)::text ~* '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'::text))
);