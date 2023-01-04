use axum::Router;

use crate::setup::AppState;

pub mod ehr;
pub mod system;

pub fn get_routes() -> Router<AppState> {
    Router::new()
        .merge(system::get_routes())
        .merge(ehr::get_routes())
}
