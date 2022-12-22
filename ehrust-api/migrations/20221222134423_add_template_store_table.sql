create table template_store (
    id uuid not null,
    template_id text not null,
    "content" text null,
    sys_transaction timestamp not null,
    "namespace" uuid not null,
    constraint template_store_pkey primary key (id, template_id, "namespace")
);