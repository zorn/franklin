defmodule FranklinWeb.Context do
  @behaviour Plug
  import Plug.Conn

  alias Franklin.Accounts.User

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{user_id: user_id}} <- FranklinWeb.Authentication.verify(token),
         %User{} = user <- Franklin.Accounts.get_user(user_id) do
      %{current_user: user}
    else
      _ ->
        %{}
    end
  end
end
