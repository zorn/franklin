defmodule FranklinWeb.Resolvers.Accounts do
  alias Franklin.Accounts
  alias Franklin.Accounts.User

  # FIXME: Move this secret out of the codebase.
  # https://github.com/zorn/franklin/issues/270
  @user_salt "BfKdyzDoplaUL48rGdb0YMNwA9ewxZGECkwdubiA568ujL5QjD8WL5N5dV1L4ZU"

  def login(_, %{email: email, password: password}, _) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        {:error, "incorrect email or password"}

      %User{id: id} = user ->
        payload = %{user_id: id}
        token = Phoenix.Token.sign(FranklinWeb.Endpoint, @user_salt, payload)

        dbg(user)
        {:ok, %{token: token, user: user}}
    end
  end
end
