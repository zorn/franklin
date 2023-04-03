defmodule FranklinWeb.AdminUserStories.CanVisitArticleViewerTest do
  @moduledoc """
  Asserts the business rule that an authenticated admin can visit the article
  viewer and see a rendered article.
  """

  use FranklinWeb.ConnCase

  setup :register_and_log_in_user

  setup %{conn: conn} do
    title = "An article test headline."

    body = """
    # Markdown Headline

    With a [link](http://example.com)!
    """

    published_at = DateTime.utc_now()

    article = create_article!(%{title: title, body: body, published_at: published_at})
    {:ok, view, _html} = live(conn, "/admin/articles/#{article.id}")

    ~M{view, article}
  end

  test "page renders expected Markdown content", ~M{view, _article} do
    assert has_element?(view, "#article-headline", "An article test headline.")
    assert has_element?(view, "#article-body h1", "Markdown Headline")
    assert has_element?(view, ~s(#article-body a[href="http://example.com"]), "link")
  end
end
