create table compo_xref (
    master_uuid uuid references composition(id),
    child_uuid uuid references composition(id),
    sys_transaction timestamp not null,
    "namespace" uuid not null
);

create index compo_xref_child_idx on compo_xref using btree (child_uuid, "namespace");
create index ehr_compo_xref on compo_xref using btree (master_uuid, "namespace");
