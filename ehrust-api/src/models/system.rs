use serde::Serialize;
use sqlx::PgPool;
use uuid::Uuid;

use crate::errors::ApiError;

#[derive(Clone, Serialize)]
pub struct System {
    pub id: Uuid,
    pub description: String,
    pub settings: String,
}

impl System {
    pub async fn create(pool: &PgPool) -> Result<System, ApiError> {
        sqlx::query_as!(
            System,
            r#"
                INSERT INTO system (description, settings)
                VALUES ('DEFAULT RUNNING SYSTEM', 'local.ehrust.org')
                RETURNING id, description, settings
            "#
        )
        .fetch_one(pool)
        .await
        .map_err(|e| ApiError::sqlx(e))
    }

    pub async fn get_one(pool: &PgPool) -> Option<System> {
        sqlx::query_as!(
            System,
            r#"
                SELECT id, description, settings FROM system
                LIMIT 1
            "#
        )
        .fetch_one(pool)
        .await
        .ok()
    }
}
