use clap::{arg, Parser};

#[derive(Parser)]
pub struct Config {
    #[arg(long, env)]
    pub database_url: String,
    #[arg(long, env)]
    pub axum_url: String,
}
