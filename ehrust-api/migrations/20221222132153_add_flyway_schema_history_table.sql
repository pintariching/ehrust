create table flyway_schema_history (
    installed_rank int4 primary key not null,
    "version" varchar(50),
    "description" varchar(200) not null,
    "type" varchar(20) not null,
    script varchar(1000) not null,
    checksum int4,
    installed_by varchar(100) not null,
    installed_on timestamp not null default now(),
    execution_time int4 not null,
    success bool not null
);

create index flyway_schema_history_s_idx on flyway_schema_history using btree (success);