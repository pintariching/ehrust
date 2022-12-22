CREATE OR REPLACE VIEW ehr_status
AS SELECT ehr.id,
    party.name,
    party.party_ref_value AS ref,
    party.party_ref_scheme AS scheme,
    party.party_ref_namespace AS namespace,
    party.party_ref_type AS type,
    identifier.id_value,
    identifier.issuer,
    identifier.assigner,
    identifier.type_name,
    identifier.party
FROM ehr ehr
    JOIN status status ON status.ehr_id = ehr.id
    JOIN party_identified party ON status.party = party.id
    LEFT JOIN identifier identifier ON identifier.party = party.id;