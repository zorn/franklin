defmodule FranklinWeb.Authentication do
  @moduledoc """
  Authentication functions for the GraphQL API.
  """

  # FIXME: Move this secret out of the codebase.
  # https://github.com/zorn/franklin/issues/270
  @user_salt "BfKdyzDoplaUL48rGdb0YMNwA9ewxZGECkwdubiA568ujL5QjD8WL5N5dV1L4ZU"

  def sign(data) do
    Phoenix.Token.sign(FranklinWeb.Endpoint, @user_salt, data)
  end

  def verify(token) do
    Phoenix.Token.verify(FranklinWeb.Endpoint, @user_salt, token, max_age: 365 * 24 * 3600)
  end
end
