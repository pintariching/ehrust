CREATE TABLE status (
	id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
	ehr_id uuid NOT NULL REFERENCES ehr(id),
	is_queryable bool NOT NULL DEFAULT true,
	is_modifiable bool NOT NULL DEFAULT true,
	party uuid NOT NULL,
	other_details jsonb NULL,
	sys_transaction timestamp NOT NULL,
	sys_period tstzrange NOT NULL,
	has_audit uuid NOT NULL,
	attestation_ref uuid NULL,
	in_contribution uuid NOT NULL,
	archetype_node_id text NOT NULL,
	"namespace" text NOT NULL,
	CONSTRAINT status_ehr_id_key UNIQUE (ehr_id, "namespace")
);


-- ehr.status foreign keys

ALTER TABLE ehr.status ADD CONSTRAINT status_attestation_ref_fkey FOREIGN KEY (attestation_ref) REFERENCES ehr.attestation_ref("ref") ON DELETE CASCADE;
ALTER TABLE ehr.status ADD CONSTRAINT status_ehr_id_fkey FOREIGN KEY (ehr_id) REFERENCES ehr.ehr(id) ON DELETE CASCADE;
ALTER TABLE ehr.status ADD CONSTRAINT status_has_audit_fkey FOREIGN KEY (has_audit) REFERENCES ehr.audit_details(id) ON DELETE CASCADE;
ALTER TABLE ehr.status ADD CONSTRAINT status_in_contribution_fkey FOREIGN KEY (in_contribution) REFERENCES ehr.contribution(id) ON DELETE CASCADE;
ALTER TABLE ehr.status ADD CONSTRAINT status_party_fkey FOREIGN KEY (party) REFERENCES ehr.party_identified(id);