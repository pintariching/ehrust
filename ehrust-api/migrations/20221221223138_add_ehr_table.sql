-- storeComposition ehr_im entities
-- EHR Class emr_im 4.7.1
create table ehr (
    id uuid unique primary key default uuid_generate_v4(),
    date_created timestamp default current_date,
    date_created_tzid text, -- timezone id: gmt+/-hh:mm
    access uuid references access(id), -- access decision support (f.e. consent)
    system_id uuid references "system"(id),
    --directory uuid null references folder(id),
    "namespace" uuid null
);

--create unique index ehr_folder_idx on ehr using btree (directory, namespace);
comment on table ehr is 'ehr itself';
