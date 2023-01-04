use std::fmt::Display;

use axum::http::StatusCode;
use axum::response::{IntoResponse, Response};
use axum::Json;
use serde::Serialize;

#[derive(Debug, Serialize)]
pub enum ApiError {
    NotFound,
    UnprocessableEntity(String),
    Sqlx(String),
    ServerError(String),
}

impl ApiError {
    pub fn sqlx(error: sqlx::Error) -> Self {
        match &error {
            sqlx::Error::Database(dbe) => ApiError::Sqlx(error.to_string()),
            sqlx::Error::RowNotFound => ApiError::NotFound,
            _ => ApiError::Sqlx(error.to_string()),
        }
    }

    fn status_code(&self) -> StatusCode {
        match self {
            ApiError::NotFound => StatusCode::NOT_FOUND,
            ApiError::UnprocessableEntity(_) => StatusCode::UNPROCESSABLE_ENTITY,
            ApiError::Sqlx(_) | ApiError::ServerError(_) => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }
}

impl Display for ApiError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ApiError::NotFound => write!(f, "the requested resource was not found"),
            ApiError::UnprocessableEntity(e) => write!(f, "{}", e),
            ApiError::Sqlx(e) => write!(f, "{}", e),
            ApiError::ServerError(e) => write!(f, "{}", e),
        }
    }
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        match self {
            ApiError::UnprocessableEntity(ref e) => {
                tracing::debug!("Unprocessable entity: {}", e);
            }
            ApiError::Sqlx(ref e) => {
                tracing::debug!("SQLX error: {}", e);
            }
            ApiError::ServerError(ref e) => {
                tracing::debug!("Generic server error: {}", e);
            }
            _ => (),
        }

        (self.status_code(), Json(self.to_string())).into_response()
    }
}
