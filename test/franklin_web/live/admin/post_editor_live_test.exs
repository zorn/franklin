defmodule FranklinWeb.Admin.PostEditorLiveTest do
  use FranklinWeb.ConnCase

  alias Franklin.Posts
  alias Franklin.Posts.Projections.Post

  setup %{conn: conn} do
    %{conn: add_authentication(conn, "zorn", "Pass1234")}
  end

  test "user can submit new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/posts/editor/new")

    view
    |> form("#new-post", form: %{title: "A valid new post title."})
    |> render_submit()

    assert {"/admin/posts/" <> id, _flash} = assert_redirect(view)
    assert %Post{title: "A valid new post title."} = Posts.get_post(id)
  end

  test "user must have a title to submit a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/posts/editor/new")

    view
    |> form("#new-post", form: %{title: ""})
    |> render_submit()

    assert has_element?(view, query_selector_for_error_feedback(:title), "can't be blank")
  end

  test "user must have a published_at date time to submit a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/admin/posts/editor/new")

    view
    |> form("#new-post", form: %{published_at: ""})
    |> render_submit()

    assert has_element?(view, query_selector_for_error_feedback(:published_at), "can't be blank")
  end

  # Future test ideas:
  #
  # A test to validate the error flash message when `Posts.update_post/2` or
  # `Posts.create_post/1` returns the error tuple. Not sure how easy it would be
  # to stage that kind of behavior.

  defp query_selector_for_error_feedback(field_name) do
    "span[phx-feedback-for='form[#{field_name}]']"
  end

  defp add_authentication(conn, username, password) do
    put_req_header(conn, "authorization", "Basic " <> Base.encode64("#{username}:#{password}"))
  end
end
