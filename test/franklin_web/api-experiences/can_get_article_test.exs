defmodule FranklinWeb.ApiExperiences.CanGetArticleTest do
  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    published_article = create_article!(%{published_at: DateTime.utc_now()})
    ~M{conn, published_article}
  end

  @query """
  query Article($id: ID!) {
    article(id: $id) {
      id
      title
      body
      slug
      publishedAt
    }
  }
  """
  test "returns an article by id", ~M{conn, published_article} do
    conn = get(conn, "/api", query: @query, variables: %{id: published_article.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "article" => %{
                 "id" => published_article.id,
                 "title" => published_article.title,
                 "body" => published_article.body,
                 "slug" => published_article.slug,
                 "publishedAt" => DateTime.to_iso8601(published_article.published_at)
               }
             }
           }
  end

  test "returns not found error message when no article with the given id exists", ~M{conn} do
    conn = get(conn, "/api", query: @query, variables: %{id: Ecto.UUID.generate()})

    assert json_response(conn, 200) == %{
             "data" => %{"article" => nil},
             "errors" => [
               %{
                 "message" => "article_not_found",
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "path" => ["article"]
               }
             ]
           }
  end

  # SOMEDAY MAYBE: Add test for non uuid looking string "not-a-uuid".
end
