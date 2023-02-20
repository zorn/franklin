defmodule FranklinWeb.PublicUserStories.CanViewArticleArchiveListTest do
  @moduledoc """
  Asserts the business rule that a website visitor can view a list of article
  links on the main archive index page.
  """

  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    articles =
      -1..-10
      |> Enum.map(fn n ->
        published_at = DateTime.add(DateTime.utc_now(), n, :day) |> DateTime.truncate(:second)
        create_article!(~M{published_at})
      end)

    {:ok, view, _html} = live(conn, "/articles/")

    ~M{view, articles}
  end

  test "page renders expected list of article titles with links", ~M{view, articles} do
    for article <- articles do
      assert has_element?(view, ~s(a[href="/articles/#{article.slug}"]), article.title)
    end
  end
end
