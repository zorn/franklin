defmodule FranklinWeb.Schema.Middleware.Authorize do
  @moduledoc """
  Defines a middleware that checks for a current user in the context and if none
  is present, returns an `unauthorized` error.
  """

  @behaviour Absinthe.Middleware

  def call(resolution, _) do
    with %{current_user: _current_user} <- resolution.context do
      resolution
    else
      _ ->
        Absinthe.Resolution.put_result(resolution, {:error, "unauthorized"})
    end
  end
end
