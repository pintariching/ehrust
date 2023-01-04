CREATE TABLE ehr (
	id uuid PRIMARY KEY UNIQUE DEFAULT uuid_generate_v4(),
	created_at timestamp NOT NULL DEFAULT NOW(),
	system_id uuid REFERENCES system(id) NOT NULL ,
	"namespace" text NOT NULL
);
