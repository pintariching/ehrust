CREATE TABLE system (
	id uuid PRIMARY KEY UNIQUE DEFAULT uuid_generate_v4(),
	"description" text NOT NULL,
	settings text NOT NULL
);