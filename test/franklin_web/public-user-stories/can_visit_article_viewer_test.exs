defmodule FranklinWeb.PublicUserStories.CanVisitArticleViewerTest do
  @moduledoc """
  Asserts the business rule that an website visitor can via the article
  viewer see a rendered article.
  """

  use FranklinWeb.ConnCase

  alias Franklin.Articles
  alias Franklin.Articles.Article

  setup %{conn: conn} do
    article = create_sample_article()
    {:ok, view, _html} = live(conn, "/admin/articles/#{article.id}")

    ~M{view, article}
  end
end
