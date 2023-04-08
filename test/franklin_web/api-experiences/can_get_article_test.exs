defmodule FranklinWeb.ApiExperiences.CanGetArticleTest do
  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    published_article = create_article!(%{published_at: DateTime.utc_now()})
    unpublished_article = create_article!(%{published_at: nil})
    ~M{conn, published_article, unpublished_article}
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
  test "returns an published article by id", ~M{conn, published_article} do
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

  test "returns an unpublished article by id", ~M{conn, unpublished_article} do
    conn = get(conn, "/api", query: @query, variables: %{id: unpublished_article.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "article" => %{
                 "id" => unpublished_article.id,
                 "title" => unpublished_article.title,
                 "body" => unpublished_article.body,
                 "slug" => unpublished_article.slug,
                 "publishedAt" => nil
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
end
