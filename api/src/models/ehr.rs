use chrono::NaiveDateTime;
use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::{errors::ApiError, setup::AppState};

#[derive(Serialize)]
pub struct Ehr {
    pub id: Uuid,
    pub created_at: NaiveDateTime,
    pub system_id: Uuid,
    pub namespace: String,
}

impl Ehr {
    pub async fn create(pool: &PgPool, state: &AppState) -> Result<Ehr, ApiError> {
        sqlx::query_as!(
            Ehr,
            r#"
                INSERT INTO ehr (system_id, namespace)
                VALUES ($1, $2)
                RETURNING id, created_at, system_id, namespace
            "#,
            state.system.id,
            state.namespace
        )
        .fetch_one(pool)
        .await
        .map_err(ApiError::sqlx)
    }

    pub async fn get_by_id(pool: &PgPool, id: Uuid) -> Result<Ehr, ApiError> {
        sqlx::query_as!(
            Ehr,
            r#"
                SELECT * FROM ehr
                WHERE id = $1
            "#,
            id
        )
        .fetch_one(pool)
        .await
        .map_err(ApiError::sqlx)
    }
}

#[derive(Serialize)]
pub struct SystemId {
    value: Uuid,
}

#[derive(Serialize)]
pub struct EhrId {
    value: Uuid,
}

#[derive(Serialize)]
pub struct EhrStatus {
    id: Id,
    namespace: String,
    #[serde(rename = "type")]
    _type: String,
}

#[derive(Serialize)]
pub struct Id {
    _type: String,
    value: String,
}

#[derive(Serialize)]
pub struct EhrAccess {
    id: Id,
    namespace: String,
    #[serde(rename = "type")]
    _type: String,
}

#[derive(Serialize)]
pub struct TimeCreated {
    value: NaiveDateTime,
}

#[derive(Serialize)]
pub struct EhrResponse {
    system_id: SystemId,
    ehr_id: EhrId,
    ehr_status: EhrStatus,
    ehr_access: EhrAccess,
    time_created: TimeCreated,
}

impl EhrResponse {
    pub fn from_ehr(ehr: Ehr) -> Self {
        Self {
            system_id: SystemId {
                value: ehr.system_id,
            },
            ehr_id: EhrId { value: ehr.id },
            ehr_status: EhrStatus {
                id: Id {
                    _type: "OBJECT_VERSION_ID".into(),
                    value: "TODO!!".into(),
                },
                namespace: ehr.namespace.clone(),
                _type: "EHR_STATUS".into(),
            },
            ehr_access: EhrAccess {
                id: Id {
                    _type: "OBJECT_VERSION_ID".into(),
                    value: "TODO!!".into(),
                },
                namespace: ehr.namespace,
                _type: "EHR_ACCESS".into(),
            },
            time_created: TimeCreated {
                value: ehr.created_at,
            },
        }
    }
}
