defmodule FranklinWeb.ApiExperiences.CanGetLoginTokenTest do
  use FranklinWeb.ConnCase

  import Franklin.AccountsFixtures

  @query """
  mutation Login($email: String!, $password: String!) {
    login(email: $email, password: $password) {
      token
      user {
        id
        email
      }
    }
  }
  """
  test "returns a session token for valid user credentials", ~M{conn} do
    _user = user_fixture(email: "timmy@example.com", password: "some-long-secret")

    conn =
      post(conn, "/api",
        query: @query,
        variables: %{email: "timmy@example.com", password: "some-long-secret"}
      )

    assert response = json_response(conn, 200)

    assert %{
             "data" => %{
               "login" => %{
                 "token" => token,
                 "user" => %{
                   "email" => "timmy@example.com",
                   "id" => id
                 }
               }
             }
           } = response

    assert_is_uuid(id)
    assert_looks_like_token(token)
    # TODO: validate that the token can be used for a subsequent request.
  end

  test "returns an error for invalid user credentials", ~M{conn} do
    conn =
      post(conn, "/api",
        query: @query,
        variables: %{email: "nick@example.com", password: "bogus-password"}
      )

    assert response = json_response(conn, 200)

    assert %{
             "data" => %{
               "login" => nil
             },
             "errors" => [
               %{
                 "locations" => _,
                 "message" => "incorrect email or password",
                 "path" => ["login"]
               }
             ]
           } = response
  end

  defp assert_is_uuid(value) do
    assert {:ok, _uuid} = Ecto.UUID.cast(value)
  end

  defp assert_looks_like_token(value) do
    assert String.length(value) == 150
  end
end
