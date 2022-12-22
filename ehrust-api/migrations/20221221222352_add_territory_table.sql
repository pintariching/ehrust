create table territory (
    code int4 unique primary key not null,
    twoletter bpchar(2),
    threeletter bpchar(3),
    "text" text not null
);

create unique index ehr_territory_twoletter_idx on territory using btree (twoletter);
create unique index territory_code_index on territory using btree (code);
comment on table territory is 'ISO 3166-1 countries codeset';
