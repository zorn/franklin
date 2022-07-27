defmodule Franklin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Franklin.Repo,
      # Start the Telemetry supervisor
      FranklinWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Franklin.PubSub},
      # Start the Endpoint (http/https)
      FranklinWeb.Endpoint,
      # Start the Commanded Application
      Franklin.CommandedApplication,
      # Start the supervisor for Post projections
      Franklin.Posts.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FranklinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
