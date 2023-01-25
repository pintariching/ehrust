use serde::{Deserialize, Serialize};
use sqlx::Type;

#[derive(Type, Serialize, Deserialize)]
#[sqlx(type_name = "contribution_change_type", rename_all = "snake_case")]
pub enum ContributionChangeType {
    Creation,
    Amendment,
    Modification,
    Synthesis,
    Unknown,
    Deleted,
}

#[derive(Type, Serialize, Deserialize)]
#[sqlx(type_name = "contribution_data_type", rename_all = "snake_case")]
pub enum ContributionDataType {
    Composition,
    Folder,
    Ehr,
    System,
    Other,
}

#[derive(Type, Serialize, Deserialize)]
#[sqlx(type_name = "contribution_state", rename_all = "snake_case")]
pub enum ContributionState {
    Complete,
    Incomplete,
    Deleted,
}

#[derive(Type, Serialize, Deserialize)]
#[sqlx(type_name = "entry_type", rename_all = "snake_case")]
pub enum EntryType {
    Section,
    CareEntry,
    Admin,
    Proxy,
}

#[derive(Debug, Type, Serialize, Deserialize)]
#[sqlx(type_name = "party_ref_id_type", rename_all = "snake_case")]
pub enum PartyRefIdType {
    GenericId,
    ObjectVersionId,
    HierObjectId,
    Undefied,
}

#[derive(Debug, Type, Serialize, Deserialize)]
#[sqlx(type_name = "party_type", rename_all = "snake_case")]
pub enum PartyType {
    PartyIdentified,
    PartySelf,
    PartyRelated,
}
