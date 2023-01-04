use clap::Parser;
use ehrust_api::Config;
use sqlx::postgres::PgPoolOptions;
use tracing::{debug, error};
use tracing_subscriber::fmt::layer;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::EnvFilter;

use ehrust_api::serve;

#[tokio::main]
async fn main() {
    dotenvy::dotenv().ok();

    tracing_subscriber::registry()
        .with(
            EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "ehrust=debug,ehrust-api=debug,tower_http=debug".into()),
        )
        .with(layer())
        .init();

    debug!("Parsing config from CLI or .env file");
    let config = Config::parse();

    debug!("Setting up connection pool");
    let pool = match PgPoolOptions::new()
        .max_connections(50)
        .connect(&std::env::var("DATABASE_URL").unwrap())
        .await
    {
        Ok(pool) => pool,
        Err(e) => {
            error!("{}", e);
            panic!();
        }
    };

    debug!("Running SQLx migrations");
    match sqlx::migrate!().run(&pool).await {
        Ok(_) => (),
        Err(e) => {
            error!("{}", e);
            panic!();
        }
    };

    serve(config, pool).await
}
