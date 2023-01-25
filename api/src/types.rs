use axum::http::HeaderValue;

#[derive(Debug)]
pub enum PreferHeader {
    Minimal,
    Representation,
}

impl From<&HeaderValue> for PreferHeader {
    fn from(value: &HeaderValue) -> Self {
        // header should be a value like "return=minimal" or "return=representation"
        if let Ok(header) = value.to_str() {
            if let Some((name, value)) = header.split_once('=') {
                if name == "return" {
                    return match value {
                        "minimal" => Self::Minimal,
                        "representation" => Self::Representation,
                        _ => Self::Minimal,
                    };
                }
            };
        };

        Self::Minimal
    }
}
