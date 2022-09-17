defmodule FranklinWeb.Admin.PostIndexLive do
  use FranklinWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(posts: Franklin.Posts.list_posts())
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <p><%= link "New Post", to: Routes.post_editor_path(@socket, :new) %></p>

    <p>Hello index!</p>

    <%= for post <- @posts do %>
      <p> <%= link post.title, to: Routes.post_details_path(@socket, :details, post.id) %> published: <%= IO.inspect(post.published_at) %></p>
    <% end %>
    """
  end

  defp ok(socket), do: {:ok, socket}
end
