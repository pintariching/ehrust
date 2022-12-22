create table terminology_provider (
    code text unique primary key not null,
    "source" text not null,
    authority text,
    "namespace" uuid not null
);

comment on table terminology_provider is 'openEHR identified terminology provider';
