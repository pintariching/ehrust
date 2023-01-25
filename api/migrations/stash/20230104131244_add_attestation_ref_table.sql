CREATE TABLE attestation_ref (
	"ref" uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
	"namespace" text NOT NULL
);