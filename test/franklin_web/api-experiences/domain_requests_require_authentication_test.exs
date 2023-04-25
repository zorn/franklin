defmodule FranklinWeb.ApiExperiences.DomainRequestsRequireAuthenticationTest do
  use FranklinWeb.ConnCase

  @query """
  query {
    articles {
      id
    }
  }
  """
  test "articles requires authentication", ~M{conn} do
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "articles" => nil
             },
             "errors" => [
               %{
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "unauthorized",
                 "path" => ["articles"]
               }
             ]
           }
  end

  @query """
  query Article($id: ID!) {
    article(id: $id) {
      id
    }
  }
  """
  test "article requires authentication", ~M{conn} do
    published_article = create_article!(%{published_at: DateTime.utc_now()})

    conn = get(conn, "/api", query: @query, variables: %{id: published_article.id})

    assert json_response(conn, 200) == %{
             "data" => %{
               "article" => nil
             },
             "errors" => [
               %{
                 "locations" => [%{"column" => 3, "line" => 2}],
                 "message" => "unauthorized",
                 "path" => ["article"]
               }
             ]
           }
  end

  @query """
  mutation {
    generateUploadUrl(filename: "demo.jpg") {
      url
    }
  }
  """
  test "generateUploadUrl requires authentication", ~M{conn} do
    conn = post(conn, "/api", query: @query)
    assert response = json_response(conn, 200)

    %{
      "data" => %{"generateUploadUrl" => nil},
      "errors" => [
        %{
          "locations" => _,
          "message" => "unauthorized",
          "path" => ["generateUploadUrl"]
        }
      ]
    } = response
  end

  @query """
  mutation CreateArticle($title: String!, $body: String!, $slug: String!, $publishedAt: DateTime) {
    createArticle(input: {title: $title, body: $body, slug: $slug, publishedAt: $publishedAt}) {
      article_id
    }
  }
  """
  test "createArticle requires authentication", ~M{conn} do
    %{
      title: title,
      body: body,
      published_at: published_at,
      slug: slug
    } = required_new_article_attributes()

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
               "createArticle" => nil
             },
             "errors" => [
               %{
                 "locations" => _,
                 "message" => "unauthorized",
                 "path" => ["createArticle"]
               }
             ]
           } = response
  end
end
