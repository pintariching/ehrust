use axum::{extract::State, response::IntoResponse, routing::get, Json, Router};

use crate::setup::AppState;

pub fn get_routes() -> Router<AppState> {
    Router::new().route("/system", get(get_current))
}

async fn get_current(State(state): State<AppState>) -> impl IntoResponse {
    Json(state.system)
}
