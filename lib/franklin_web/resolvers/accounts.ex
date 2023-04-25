defmodule FranklinWeb.Resolvers.Accounts do
  alias Franklin.Accounts
  alias Franklin.Accounts.User
  alias FranklinWeb.Authentication

  def login(_, %{email: email, password: password}, _) do
    case Accounts.get_user_by_email_and_password(email, password) do
      nil ->
        {:error, "incorrect email or password"}

      %User{id: id} = user ->
        payload = %{user_id: id}
        token = Authentication.sign(payload)
        {:ok, %{token: token, user: user}}
    end
  end
end
