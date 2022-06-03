defmodule Franklin.Repo do
  use Ecto.Repo,
    otp_app: :franklin,
    adapter: Ecto.Adapters.Postgres
end
