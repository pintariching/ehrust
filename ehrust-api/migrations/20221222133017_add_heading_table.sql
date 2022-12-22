create table heading (
    code varchar(16) primary key not null,
    "name" text,
    "description" text,
    "namespace" uuid not null
);