create table concept (
    id uuid unique primary key not null default uuid_generate_v4(),
	conceptid int4,
	"language" varchar(5) references "language"(code),
	"description" text
);

create index ehr_concept_id_language_idx on concept using btree (conceptid, "language");
comment on table concept is 'openEHR common concepts (e.g. terminology) used in the system';
