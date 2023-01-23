defmodule FranklinWeb.AdminUserStories.CanVisitArticleViewerTest do
  @moduledoc """
  Asserts the business rule that an authenticated admin can visit the article
  viewer and see a rendered article.
  """

  use FranklinWeb.ConnCase

  alias Franklin.Articles
  alias Franklin.Articles.Article

  setup %{conn: conn} do
    conn = add_authentication(conn, "zorn", "Pass1234")
    article = create_sample_article()
    {:ok, view, _html} = live(conn, "/admin/articles/#{article.id}")

    ~M{view, article}
  end

  test "page renders expected Markdown content", ~M{view, _article} do
    assert has_element?(view, "#article-headline", "An article test headline.")
    assert has_element?(view, "#article-body h1", "Markdown Headline")
    assert has_element?(view, ~s(#article-body a[href="http://example.com"]), "link")
  end

  defp add_authentication(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64("#{username}:#{password}"))
  end

  defp create_sample_article() do
    title = "An article test headline."

    body = """
    # Markdown Headline

    With a [link](http://example.com)!
    """

    published_at = DateTime.utc_now() |> DateTime.truncate(:second)

    sample_article_attributes = %{
      title: title,
      body: body,
      published_at: published_at
    }

    {:ok, sample_article_id} = Articles.create_article(sample_article_attributes)

    wait_for_passing(fn ->
      # Because projections are not instant, we need to wait until it is finished.
      assert %Article{
               title: ^title,
               body: ^body,
               published_at: ^published_at
             } = Articles.get_article(sample_article_id)
    end)
  end
end
