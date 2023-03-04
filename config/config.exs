# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :franklin,
  ecto_repos: [Franklin.Repo]

# Configures the endpoint
config :franklin, FranklinWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: FranklinWeb.ErrorHTML, json: FranklinWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Franklin.PubSub,
  live_view: [signing_salt: "ACCBZ9OX"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :franklin, Franklin.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(js/app.js js/storybook.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :franklin, Franklin.CommandedApplication,
  event_store: [
    adapter: Commanded.EventStore.Adapters.EventStore,
    event_store: Franklin.EventStore
  ],
  pubsub: :local,
  registry: :local

config :commanded_ecto_projections, repo: Franklin.Repo

config :franklin, event_stores: [Franklin.EventStore]

config :franklin, FranklinWeb.RssFeed, url: "https://mikezornek.com"

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ],
  storybook: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/storybook.css
      --output=../priv/static/assets/storybook.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
