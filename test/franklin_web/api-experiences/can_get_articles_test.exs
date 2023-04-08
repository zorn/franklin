defmodule FranklinWeb.ApiExperiences.CanGetArticlesTest do
  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    now = DateTime.utc_now()
    yesterday = DateTime.utc_now() |> DateTime.add(-1, :day)
    article1 = create_article!(%{published_at: now})
    article2 = create_article!(%{published_at: yesterday})
    article3 = create_article!(%{published_at: nil})
    ~M{conn, article1, article2, article3, now, yesterday}
  end

  @query """
  query {
    articles {
      id
      publishedAt
    }
  }
  """
  test "returns a list of published articles", ~M{conn, article1, article2} do
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "articles" => [
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
end
