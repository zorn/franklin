defmodule FranklinWeb.AdminUserStories.CanCreateArticle do
  @moduledoc """
  Asserts the business rule that an authenticated admin can create an article
  and that creation failure works as expected.
  """

  use FranklinWeb.ConnCase

  alias Franklin.Articles
  alias Franklin.Articles.Article

  setup %{conn: conn} do
    conn = add_authentication(conn, "zorn", "Pass1234")
    {:ok, view, _html} = live(conn, "/admin/articles/editor/new")

    %{view: view}
  end

  test "creation succeeds with all required form fields", %{view: view} do
    valid_params = %{
      title: "A valid new article title.",
      body: "A valid new article body."
    }

    view
    |> form("#new-article", article_form: valid_params)
    |> render_submit()

    assert {"/admin/articles", _flash} = assert_redirect(view)

    # Because the data projection can take time, we need to wait_for_passing.
    wait_for_passing(fn ->
      assert [
               %Article{
                 title: "A valid new article title.",
                 body: "A valid new article body."
               }
             ] = Articles.list_articles()
    end)
  end

  test "creation fails without a required title value", %{view: view} do
    view
    |> form("#new-article", article_form: %{title: ""})
    |> render_submit()

    assert has_element?(view, error_feedback_query(:title), "can't be blank")
  end

  test "creation fails with a title more than 255 max characters", %{view: view} do
    invalid_title = Faker.Lorem.characters(255 + 1) |> to_string()

    view
    |> form("#new-article", article_form: %{title: invalid_title})
    |> render_submit()

    assert has_element?(view, error_feedback_query(:title), "should be at most 255 character(s)")
  end

  test "creation fails without a required published_at value", %{view: view} do
    view
    |> form("#new-article", article_form: %{published_at: ""})
    |> render_submit()

    assert has_element?(view, error_feedback_query(:published_at), "can't be blank")
  end

  test "creation fails without a date-specific string published_at value", %{view: view} do
    view
    |> form("#new-article", article_form: %{published_at: "not a date"})
    |> render_submit()

    assert has_element?(view, error_feedback_query(:published_at), "is invalid")
  end

  test "creation fails without a required body value", %{view: view} do
    view
    |> form("#new-article", article_form: %{body: ""})
    |> render_submit()

    assert has_element?(view, error_feedback_query(:body), "can't be blank")
  end

  test "creation fails with a body value of more than 30_000 characters", %{view: view} do
    invalid_body = Faker.Lorem.characters(30_000 + 1) |> to_string()

    view
    |> form("#new-article", article_form: %{body: invalid_body})
    |> render_submit()

    assert has_element?(view, error_feedback_query(:body), "should be at most 30000 character(s)")
  end

  defp error_feedback_query(field_name) do
    "span[phx-feedback-for='article_form[#{field_name}]']"
  end

  defp add_authentication(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64("#{username}:#{password}"))
  end
end
