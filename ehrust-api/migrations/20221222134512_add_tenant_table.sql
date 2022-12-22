create table tenant (
    id uuid primary key not null default uuid_generate_v4(),
    tenant_id text unique,
    tenant_name text unique
);