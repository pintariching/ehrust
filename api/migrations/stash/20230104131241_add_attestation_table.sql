-- ehr.attestation definition

-- Drop table

-- DROP TABLE ehr.attestation;

CREATE TABLE ehr.attestation (
	id uuid NOT NULL DEFAULT uuid_generate_v4(),
	proof text NULL,
	reason text NULL,
	is_pending bool NULL,
	has_audit uuid NOT NULL,
	reference uuid NOT NULL,
	"namespace" text NULL DEFAULT '1f332a66-0e57-11ed-861d-0242ac120002'::text,
	CONSTRAINT attestation_pkey PRIMARY KEY (id)
);
CREATE INDEX attestation_reference_idx ON ehr.attestation USING btree (reference, namespace);


-- ehr.attestation foreign keys

ALTER TABLE ehr.attestation ADD CONSTRAINT attestation_has_audit_fkey FOREIGN KEY (has_audit) REFERENCES ehr.audit_details(id) ON DELETE CASCADE;
ALTER TABLE ehr.attestation ADD CONSTRAINT attestation_reference_fkey FOREIGN KEY (reference) REFERENCES ehr.attestation_ref("ref") ON DELETE CASCADE;