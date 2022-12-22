create table "system" (
    id uuid primary key not null default uuid_generate_v4(),
    "description" text not null,
    settings text not null
);

create unique index ehr_system_settings_idx on "system" (settings);
comment on table system is 'system table for reference';
