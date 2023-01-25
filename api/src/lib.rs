use axum::{Router, Server};
use sqlx::PgPool;
use tower_http::trace::TraceLayer;
use tracing::{debug, error};

mod config;
mod errors;
mod extractors;
pub mod models;
mod routes;
mod setup;
mod types;

pub use config::Config;

use crate::{routes::get_routes, setup::setup_system};

pub async fn serve(config: Config, pool: PgPool) {
    debug!("Setting up the system state");
    let state = setup_system(pool).await;

    let app = Router::new()
        .nest("/api/v1", get_routes())
        .layer(TraceLayer::new_for_http())
        .with_state(state);

    let axum_url = match config.axum_url.parse() {
        Ok(addr) => {
            debug!("URL successfully parsed from the config as: {}", addr);
            addr
        }
        Err(e) => {
            error!("{}", e);
            panic!()
        }
    };

    tracing::debug!("Server is running an listening on: {}", axum_url);

    Server::bind(&axum_url)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
