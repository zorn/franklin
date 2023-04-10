defmodule FranklinWeb.ApiExperiences.CanCreateArticleTest do
  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    %{
      title: title,
      body: body,
      published_at: published_at,
      slug: slug
    } = required_new_article_attributes()

    ~M{conn, title, body, published_at, slug}
  end

  @query """
  mutation CreateArticle($title: String!, $body: String!, $slug: String!, $publishedAt: DateTime) {
    createArticle(input: {title: $title, body: $body, slug: $slug, publishedAt: $publishedAt}) {
      article_id
    }
  }
  """
  test "can create an article with valid attributes",
       ~M{conn, title, body, published_at, slug} do
    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          title: title,
          body: body,
          slug: slug,
          publishedAt: DateTime.to_iso8601(published_at)
        }
      )

    assert response = json_response(conn, 200)

    assert %{
             "data" => %{
               "createArticle" => %{
                 "article_id" => id
               }
             }
           } = response

    assert {:ok, _uuid} = Ecto.UUID.cast(id)
  end

  test "returns error message when trying to create an article with invalid attributes",
       ~M{conn, _title, body, published_at, _slug} do
    conn =
      post(conn, "/api",
        query: @query,
        variables: %{
          title: "",
          body: body,
          slug: "",
          publishedAt: DateTime.to_iso8601(published_at)
        }
      )

    assert response = json_response(conn, 200)

    assert %{
             "data" => %{
               "createArticle" => nil
             },
             "errors" => [
               %{
                 "details" => %{
                   "title" => ["can't be blank"],
                   "slug" => ["can't be blank"]
                 },
                 "locations" => _,
                 "message" => "A database error occurred",
                 "path" => ["createArticle"]
               }
             ]
           } = response
  end
end
