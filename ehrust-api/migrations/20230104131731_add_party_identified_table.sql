CREATE TABLE party_identified (
	id uuid PRIMARY KEY UNIQUE DEFAULT uuid_generate_v4(),
	"name" text,
	party_ref_value text,
	party_ref_scheme text,
	party_ref_namespace text,
	party_ref_type text,
	party_type text NOT NULL,
	relationship dv_coded_text,
	object_id_type text NOT NULL,
	"namespace" text NOT NULL
);