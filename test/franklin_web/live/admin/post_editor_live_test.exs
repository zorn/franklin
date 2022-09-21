defmodule FranklinWeb.Admin.PostEditorLiveTest do
  use FranklinWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Franklin.Posts
  alias Franklin.Posts.Projections.Post

  test "user can submit new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.post_editor_path(conn, :new))

    view
    |> form("#new-post", form: %{title: "A valid new post title."})
    |> render_submit()

    assert {"/admin/posts/" <> id, _flash} = assert_redirect(view)
    assert %Post{title: "A valid new post title."} = Posts.get_post(id)
  end

  test "user must have a title to submit a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.post_editor_path(conn, :new))

    view
    |> form("#new-post", form: %{title: ""})
    |> render_submit()

    assert has_element?(view, query_selector_for_error_feedback(:title), "can't be blank")
  end

  test "user must have a published_at date time to submit a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.post_editor_path(conn, :new))

    view
    |> form("#new-post", form: %{published_at: ""})
    |> render_submit()

    assert has_element?(view, query_selector_for_error_feedback(:published_at), "can't be blank")
  end

  defp query_selector_for_error_feedback(field_name) do
    "span[phx-feedback-for='form[#{field_name}]']"
  end
end
