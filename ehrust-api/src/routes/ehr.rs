use axum::{extract::State, http::StatusCode, response::IntoResponse, routing::post, Json, Router};

use crate::models::ehr::{Ehr, EhrResponse};
use crate::setup::AppState;

pub fn get_routes() -> Router<AppState> {
    Router::new().route("/ehr", post(insert))
}

async fn insert(State(state): State<AppState>) -> impl IntoResponse {
    Ehr::create(&state.pool, &state)
        .await
        .map(|ehr| (StatusCode::CREATED, Json(EhrResponse::from_ehr(ehr))))
        .map_err(|_| StatusCode::CONFLICT)
}
