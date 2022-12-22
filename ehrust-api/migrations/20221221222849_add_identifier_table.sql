-- list of identifiers for a party identified
create table identifier (
    id_value text, -- identifier value
    issuer text, -- authority responsible for the identification (ex. france asip, ldap server etc.)
    assigner text, -- assigner of the identifier
    type_name text, -- coding origin f.ex. ins-c, ins-a, nhs etc.
    party uuid not null references party_identified(id), -- entity identified with this identifier (normally a person, patient etc.)
    "namespace" uuid not null
);

create index ehr_identifier_party_idx on identifier using btree (party, "namespace");
create index identifier_value_idx on identifier using btree (id_value, "namespace");
comment on table identifier is 'specifies an identifier for a party identified, more than one identifier is possible';

