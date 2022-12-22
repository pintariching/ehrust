create table composition (
    id uuid primary key default uuid_generate_v4(),
    ehr_id uuid references ehr(id) on delete cascade,
	in_contribution uuid references contribution(id) on delete cascade,
	active bool default true,
	is_persistent bool default true,
	"language" varchar(5) references "language"(code),
	territory int4 references territory(code),
	composer uuid not null references party_identified(id),
	sys_transaction timestamp not null,
	sys_period tstzrange not null,
	has_audit uuid references audit_details(id) on delete cascade,
	attestation_ref uuid references attestation_ref("ref") on delete cascade,
	feeder_audit jsonb,
	links jsonb,
    "namespace" uuid not null
);

create index composition_composer_idx on composition using btree (composer, namespace);
create index composition_ehr_idx on composition using btree (ehr_id, namespace);

create trigger versioning_trigger before insert
or delete
or update on
composition for each row execute function versioning('sys_period', 'composition_history', 'true');
