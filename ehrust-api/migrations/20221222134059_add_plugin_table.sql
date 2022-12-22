create table plugin (
    id uuid primary key not null default uuid_generate_v4(),
    pluginid text not null,
    "key" text not null,
    value text
);