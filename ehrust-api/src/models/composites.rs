use serde::{Deserialize, Serialize};
use sqlx::Type;

#[derive(Debug, Serialize, Deserialize, Type)]
#[sqlx(type_name = "code_phrase")]
pub struct CodePhrase {
    terminology_id_value: String,
    code_string: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DvCodedText {
    value: String,
    defining_code: CodePhrase,
    formatting: String,
    language: CodePhrase,
    encoding: CodePhrase,
    term_mapping: String,
}

// Custom implementations for sqlx::Type, sqlx::Encode and sqlx::Decode are required
// because sqlx 0.6.2 doesn't currently support nested composites

impl sqlx::Type<::sqlx::Postgres> for DvCodedText {
    fn type_info() -> sqlx::postgres::PgTypeInfo {
        sqlx::postgres::PgTypeInfo::with_name("dv_coded_text")
    }
}

impl sqlx::encode::Encode<'_, sqlx::Postgres> for DvCodedText
where
    String: for<'q> sqlx::encode::Encode<'q, sqlx::Postgres>,
    String: sqlx::types::Type<sqlx::Postgres>,
    CodePhrase: for<'q> sqlx::encode::Encode<'q, sqlx::Postgres>,
    CodePhrase: sqlx::types::Type<sqlx::Postgres>,
    String: for<'q> sqlx::encode::Encode<'q, sqlx::Postgres>,
    String: sqlx::types::Type<::sqlx::Postgres>,
    CodePhrase: for<'q> sqlx::encode::Encode<'q, sqlx::Postgres>,
    CodePhrase: sqlx::types::Type<sqlx::Postgres>,
    CodePhrase: for<'q> sqlx::encode::Encode<'q, sqlx::Postgres>,
    CodePhrase: sqlx::types::Type<sqlx::Postgres>,
    String: for<'q> sqlx::encode::Encode<'q, sqlx::Postgres>,
    String: sqlx::types::Type<sqlx::Postgres>,
{
    fn encode_by_ref(&self, buf: &mut sqlx::postgres::PgArgumentBuffer) -> sqlx::encode::IsNull {
        let mut encoder = sqlx::postgres::types::PgRecordEncoder::new(buf);
        encoder.encode(&self.value);
        encoder.encode(&self.defining_code);
        encoder.encode(&self.formatting);
        encoder.encode(&self.language);
        encoder.encode(&self.encoding);
        encoder.encode(&self.term_mapping);
        encoder.finish();
        ::sqlx::encode::IsNull::No
    }
    fn size_hint(&self) -> std::primitive::usize {
        6usize * (4 + 4)
            + <String as sqlx::encode::Encode<sqlx::Postgres>>::size_hint(&self.value)
            + <CodePhrase as sqlx::encode::Encode<sqlx::Postgres>>::size_hint(&self.defining_code)
            + <String as sqlx::encode::Encode<sqlx::Postgres>>::size_hint(&self.formatting)
            + <CodePhrase as sqlx::encode::Encode<sqlx::Postgres>>::size_hint(&self.language)
            + <CodePhrase as sqlx::encode::Encode<sqlx::Postgres>>::size_hint(&self.encoding)
            + <String as sqlx::encode::Encode<sqlx::Postgres>>::size_hint(&self.term_mapping)
    }
}

impl<'r> sqlx::decode::Decode<'r, sqlx::Postgres> for DvCodedText
where
    String: sqlx::decode::Decode<'r, sqlx::Postgres>,
    String: sqlx::types::Type<sqlx::Postgres>,
    CodePhrase: for<'q> sqlx::decode::Decode<'q, sqlx::Postgres>,
    CodePhrase: sqlx::types::Type<sqlx::Postgres>,
    String: sqlx::decode::Decode<'r, sqlx::Postgres>,
    String: sqlx::types::Type<sqlx::Postgres>,
    CodePhrase: for<'q> sqlx::decode::Decode<'q, sqlx::Postgres>,
    CodePhrase: sqlx::types::Type<sqlx::Postgres>,
    CodePhrase: for<'q> sqlx::decode::Decode<'q, sqlx::Postgres>,
    CodePhrase: sqlx::types::Type<sqlx::Postgres>,
    String: sqlx::decode::Decode<'r, sqlx::Postgres>,
    String: sqlx::types::Type<sqlx::Postgres>,
{
    fn decode(
        value: sqlx::postgres::PgValueRef<'r>,
    ) -> std::result::Result<
        Self,
        std::boxed::Box<dyn std::error::Error + 'static + std::marker::Send + std::marker::Sync>,
    > {
        let mut decoder = sqlx::postgres::types::PgRecordDecoder::new(value)?;
        let value = decoder.try_decode::<String>()?;
        let defining_code = decoder.try_decode::<CodePhrase>()?;
        let formatting = decoder.try_decode::<String>()?;
        let language = decoder.try_decode::<CodePhrase>()?;
        let encoding = decoder.try_decode::<CodePhrase>()?;
        let term_mapping = decoder.try_decode::<String>()?;
        std::result::Result::Ok(DvCodedText {
            value,
            defining_code,
            formatting,
            language,
            encoding,
            term_mapping,
        })
    }
}
