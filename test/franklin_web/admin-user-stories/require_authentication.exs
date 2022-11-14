defmodule FranklinWeb.AdminUserStories.RequireAuthentication do
  @moduledoc """
  Asserts the business rule that anyone attempting to load the admin area needs
  to be authenticated.

  ## Technical Notes

  While `FranklinWeb.Admin.IndexLive` is a live view we avoid using
  `Phoenix.LiveViewTest.live/2` to initialize our tests since it does not
  currently handle `401` the response status. We use `Phoenix.ConnTest.get/1`
  instead.
  """

  use FranklinWeb.ConnCase

  test "success: with valid credentials I can view the admin area", %{conn: conn} do
    conn
    |> add_authentication("zorn", "Pass1234")
    |> get("/admin")
    |> assert_html_response(200, "Welcome to the Admin area.")
  end

  test "failure: with invalid credentials I can not view the admin area", %{conn: conn} do
    conn
    |> add_authentication("hacker", "badsecret")
    |> get("/admin")
    |> assert_response(401)
  end

  test "failure: with missing credentials I can not view the admin area", %{conn: conn} do
    conn
    |> get("/admin")
    |> assert_response(401)
  end

  defp add_authentication(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64("#{username}:#{password}"))
  end

  defp assert_html_response(conn, status, expected_html) do
    assert html_response(conn, status) =~ expected_html

    conn
  end

  defp assert_response(conn, status) do
    assert response(conn, status)

    conn
  end
end
