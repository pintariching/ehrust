create or replace view comp_expand
as select ehr.id as ehr_id,
    party.party_ref_value as subject_externalref_id_value,
    party.party_ref_namespace as subject_externalref_id_namespace,
    entry.composition_id,
    entry.template_id,
    entry.archetype_id,
    entry.entry,
    ltrim(rtrim((regexp_split_to_array(json_object_keys(entry.entry::json), 'and name/value='::text))[2], ''']'::text), ''''::text) as composition_name,
    compo.language,
    compo.territory,
    ctx.start_time,
    ctx.start_time_tzid,
    ctx.end_time,
    ctx.end_time_tzid,
    ctx.other_context,
    ctx.location as ctx_location,
    fclty.name as facility_name,
    fclty.party_ref_value as facility_ref,
    fclty.party_ref_scheme as facility_scheme,
    fclty.party_ref_namespace as facility_namespace,
    fclty.party_ref_type as facility_type,
    compr.name as composer_name,
    compr.party_ref_value as composer_ref,
    compr.party_ref_scheme as composer_scheme,
    compr.party_ref_namespace as composer_namespace,
    compr.party_ref_type as composer_type
from "entry"
    join composition compo on compo.id = entry.composition_id
    join event_context ctx on ctx.composition_id = entry.composition_id
    join party_identified compr on compo.composer = compr.id
    join ehr ehr on ehr.id = compo.ehr_id
    join "status" "status" on status.ehr_id = ehr.id
    left join party_identified party on status.party = party.id
    left join party_identified fclty on ctx.facility = fclty.id;