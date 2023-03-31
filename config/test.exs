import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :argon2_elixir, t_cost: 1, m_cost: 8

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :franklin, Franklin.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "franklin_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :franklin, Franklin.CommandedApplication,
  event_store: [
    adapter: Commanded.EventStore.Adapters.InMemory,
    serializer: Commanded.Serialization.JsonSerializer
  ]

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :franklin, FranklinWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "1SYNG+4Dnv2J+by3bQxwxsUEoebxEHehaWeplWsxJkwUNoOr7HKXl0DBapV4XoJG",
  server: false

# In test we don't send emails.
config :franklin, Franklin.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :franklin, FranklinWeb.RssFeed, url: "https://test.mikezornek.com"

# ExAws config for local minio access:
config :ex_aws,
  access_key_id: "minioadmin",
  secret_access_key: "minioadmin"

config :ex_aws, :s3,
  host: "localhost",
  scheme: "http://",
  port: 9000
