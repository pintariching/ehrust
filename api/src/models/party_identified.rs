use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use uuid::Uuid;

use super::composites::DvCodedText;
use super::enums::{PartyRefIdType, PartyType};
use crate::errors::ApiError;

#[derive(Debug, Serialize, Deserialize)]
pub struct PartyIdentified {
    id: Uuid,
    name: Option<String>,
    party_ref_value: Option<String>,
    party_ref_scheme: Option<String>,
    party_ref_namespace: Option<String>,
    party_ref_type: Option<String>,
    party_type: PartyType,
    relationship: Option<DvCodedText>,
    object_id_type: PartyRefIdType,
    namespace: String,
}

impl PartyIdentified {
    pub async fn create(pool: &PgPool, namespace: &str) -> Result<PartyIdentified, ApiError> {
        let party_identified = PartyIdentifiedInsert::new(namespace);

        sqlx::query_as!(
            PartyIdentified,
            r#"
                INSERT INTO party_identified (
                    name, party_ref_value, party_ref_scheme, party_ref_namespace, party_ref_type,
                    party_type, relationship, object_id_type, namespace
                ) VALUES (
                    $1, $2, $3, $4, $5, $6, $7, $8, $9
                ) RETURNING
                    id, name, party_ref_value, party_ref_scheme, party_ref_namespace, party_ref_type, 
                    party_type AS "party_type: PartyType", 
                    relationship AS "relationship?: DvCodedText",
                    object_id_type AS "object_id_type: PartyRefIdType",
                    namespace;
            "#,
            party_identified.name,
            party_identified.party_ref_value,
            party_identified.party_ref_scheme,
            party_identified.party_ref_namespace,
            party_identified.party_ref_type,
            party_identified.party_type as PartyType,
            party_identified.relationship as _,
            party_identified.object_id_type as PartyRefIdType,
            party_identified.namespace
        )
        .fetch_one(pool)
        .await
        .map_err( ApiError::sqlx)
    }
}

#[derive(Serialize)]
pub struct PartyIdentifiedInsert {
    name: Option<String>,
    party_ref_value: Option<String>,
    party_ref_scheme: Option<String>,
    party_ref_namespace: Option<String>,
    party_ref_type: Option<String>,
    party_type: PartyType,
    relationship: Option<DvCodedText>,
    object_id_type: PartyRefIdType,
    namespace: String,
}

impl PartyIdentifiedInsert {
    pub fn new(namespace: &str) -> Self {
        Self {
            name: Some("EHRust".to_string()),
            party_ref_value: Some(Uuid::new_v4().to_string()),
            party_ref_scheme: Some("DEMOGRAPHIC".to_string()),
            party_ref_namespace: Some("USER".to_string()),
            party_ref_type: Some("PARTY".to_string()),
            party_type: PartyType::PartyIdentified,
            relationship: None,
            object_id_type: PartyRefIdType::GenericId,
            namespace: namespace.to_string(),
        }
    }
}
