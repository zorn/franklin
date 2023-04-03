defmodule FranklinWeb.AdminUserStories.CanNilArticlePublishedAtToRemoveFromPublicTest do
  @moduledoc """
  Asserts the business rule that an authenticated admin can mark the
  published_at value of an article with `nil` to remove it from the public
  website.
  """

  use FranklinWeb.ConnCase

  alias Franklin.Articles
  alias Franklin.Articles.Article

  setup :register_and_log_in_user

  test "previously public articles are no longer visible on public site after published_at value is set to nil",
       ~M{conn} do
    articles = [
      create_article!(%{published_at: ~U[2023-01-10 00:01:00.000000Z]}),
      create_article!(%{published_at: ~U[2023-01-11 00:01:00.000000Z]}),
      create_article!(%{published_at: ~U[2023-01-12 00:01:00.000000Z]})
    ]

    edit_article = hd(articles)

    {:ok, edit_view, _html} = live(conn, "/admin/articles/editor/#{edit_article.id}")

    {:ok, public_article_index_view, _html} = live(conn, "/articles/")

    # Check all articles are listed on public page.
    for article <- articles do
      assert has_element?(
               public_article_index_view,
               ~s(a[href="/articles/#{article.slug}"]),
               article.title
             )
    end

    edit_view
    |> form("#new_article", article_form: %{published_at: ""})
    |> render_submit()

    # After hitting save, the `nil` value is projected.
    wait_for_passing(fn ->
      assert {:ok, %Article{published_at: nil}} = Articles.fetch_article(edit_article.id)
    end)

    # Check all articles (besides the edited one) are STILL listed on public page
    {:ok, reloaded_public_article_index_view, _html} = live(conn, "/articles/")

    for article <- articles -- [edit_article] do
      assert has_element?(
               reloaded_public_article_index_view,
               ~s(a[href="/articles/#{article.slug}"]),
               article.title
             )
    end

    # Verify the no longer public article is not listed.
    refute has_element?(
             reloaded_public_article_index_view,
             ~s(a[href="/articles/#{edit_article.slug}"]),
             edit_article.title
           )

    # Verify the page is no longer available.
    assert_raise FranklinWeb.NotFoundError, fn ->
      {:ok, _view, _html} = live(conn, "/articles/#{edit_article.slug}")
    end
  end
end
