defmodule FranklinWeb.BasicAuth do
  import Plug.Conn
  @realm "Basic realm=\"Staging\""

  def init(opts),
    do: opts ++ [password: "Pass1234"]

  def call(conn, correct_auth) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> attempted_auth] -> verify(conn, attempted_auth, correct_auth)
      _ -> unauthorized(conn)
    end
  end

  defp verify(conn, attempted_auth, username: username, password: password) do
    with ^attempted_auth <- encode(username, password) do
      conn
    else
      _ -> unauthorized(conn)
    end
  end

  defp encode(username, password), do: Base.encode64(username <> ":" <> password)

  defp unauthorized(conn) do
    conn
    |> put_resp_header("www-authenticate", @realm)
    |> send_resp(401, "unauthorized")
    |> halt()
  end
end
