use sqlx::PgPool;
use tracing::{debug, error};

use crate::models::system::System;

#[derive(Clone)]
pub struct AppState {
    pub pool: PgPool,
    pub system: System,
    pub namespace: String,
}

pub async fn setup_system(pool: PgPool) -> AppState {
    if let Some(system) = System::get_one(&pool).await {
        debug!("System already exists with the ID: {}", system.id);
        AppState {
            pool,
            system,
            namespace: "local".into(),
        }
    } else {
        debug!("System not found, inserting a new record");
        let system = match System::create(&pool).await {
            Ok(system) => {
                debug!("Created a new system with the ID: {}", system.id);
                system
            }
            Err(error) => {
                error!("{:?}", error);
                panic!()
            }
        };

        AppState {
            pool,
            system,
            namespace: "local".into(),
        }
    }
}
