use clap::Parser;
use ehrust_api::Config;
use sqlx::postgres::PgPoolOptions;
use tracing::error;
use tracing_subscriber::fmt::layer;
use tracing_subscriber::layer::SubscriberExt;
use tracing_subscriber::util::SubscriberInitExt;
use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() {
    dotenv::dotenv().ok();

    tracing_subscriber::registry()
        .with(EnvFilter::new(std::env::var("RUST_LOG").unwrap_or_else(
            |_| "ehrust-api=debug,tower_http=debug".into(),
        )))
        .with(layer())
        .init();

    let config = Config::parse();

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

    match sqlx::migrate!().run(&pool).await {
        Ok(_) => (),
        Err(e) => {
            error!("{}", e);
            panic!();
        }
    };

    //serve(config, pool).await
}
