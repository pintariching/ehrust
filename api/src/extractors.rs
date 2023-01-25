use axum::{
    async_trait,
    extract::FromRequestParts,
    http::{request::Parts, StatusCode},
};

use crate::types::PreferHeader;

const PREFER: &str = "Prefer";

pub struct ExtractPrefer(pub PreferHeader);

#[async_trait]
impl<S> FromRequestParts<S> for ExtractPrefer
where
    S: Send + Sync,
{
    type Rejection = (StatusCode, &'static str);

    async fn from_request_parts(parts: &mut Parts, _state: &S) -> Result<Self, Self::Rejection> {
        if let Some(prefer) = parts.headers.get(PREFER) {
            Ok(ExtractPrefer(prefer.into()))
        } else {
            Ok(ExtractPrefer(PreferHeader::Minimal))
        }
    }
}
