defmodule FranklinWeb.Admin.PostDetailsLive do
  use FranklinWeb, :live_view

  alias Franklin.Posts

  def mount(%{"id" => id}, _session, socket) do
    post = Posts.get_post(id)

    {:ok, assign(socket, post: post)}
  end

  def render(assigns) do
    ~H"""
    <h1>Post Details</h1>

    <p><%= link "Edit Post", to: Routes.post_editor_path(@socket, :edit, @post.id) %></p>

    <p>Title: <%= @post.title %></p>

    <p>Published At: <%= inspect(@post.published_at) %></p>

    """
  end
end
