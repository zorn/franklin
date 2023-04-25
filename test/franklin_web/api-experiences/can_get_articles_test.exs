defmodule FranklinWeb.ApiExperiences.CanGetArticlesTest do
  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    now = DateTime.utc_now()
    yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)
    article1 = create_article!(%{published_at: now})
    article2 = create_article!(%{published_at: yesterday})
    article3 = create_article!(%{published_at: nil})
    conn = auth_user(conn, Franklin.AccountsFixtures.user_fixture())

    ~M{conn, article1, article2, article3}
  end

  @query """
  query {
    articles {
      id
      publishedAt
    }
  }
  """
  test "returns a list of published articles", ~M{conn, article1, article2, article3} do
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "articles" => [
                 %{
                   "id" => article3.id,
                   "publishedAt" => nil
                 },
                 %{
                   "id" => article1.id,
                   "publishedAt" => DateTime.to_iso8601(article1.published_at)
                 },
                 %{
                   "id" => article2.id,
                   "publishedAt" => DateTime.to_iso8601(article2.published_at)
                 }
               ]
             }
           }
  end

  defp auth_user(conn, user) do
    token = FranklinWeb.Authentication.sign(%{user_id: user.id})
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
end
