create table language (
    code varchar(5) unique primary key not null,
    "description" text not null
);

comment on table language is 'ISO 639-1 language codeset';
