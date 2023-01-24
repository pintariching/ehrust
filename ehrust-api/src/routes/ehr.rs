use axum::routing::get;
use axum::{extract::State, http::StatusCode, response::IntoResponse, routing::post, Json, Router};
use uuid::Uuid;

use crate::models::ehr::{Ehr, EhrResponse};
use crate::setup::AppState;

pub fn get_routes() -> Router<AppState> {
    Router::new()
        .route("/ehr", post(insert))
        .route("/ehr/{id}", get(get_by_id))
}

async fn insert(State(state): State<AppState>) -> impl IntoResponse {
    Ehr::create(&state.pool, &state)
        .await
        .map(|ehr| (StatusCode::CREATED, Json(EhrResponse::from_ehr(ehr))))
        .map_err(|_| StatusCode::CONFLICT)
}

async fn get_by_id(State(state): State<AppState>, id: Json<Uuid>) -> impl IntoResponse {
    Ehr::get_by_id(&state.pool, id.0)
        .await
        .map(|ehr| (StatusCode::OK, Json(EhrResponse::from_ehr(ehr))))
        .map_err(|_| StatusCode::NOT_FOUND)
}
