defmodule FranklinWeb.Admin.PostIndexLive do
  use FranklinWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(posts: Franklin.Posts.list_posts())
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <p>
      <.link href={~p"/admin/posts/new"}>New Post</.link>
    </p>

    <p>Hello index!</p>

    <%= for post <- @posts do %>
      <p>
        <.link href={~p"/admin/posts/#{@post}"}><%= post.title %></.link>
        published: <%= IO.inspect(post.published_at) %>
      </p>
    <% end %>
    """
  end

  defp ok(socket), do: {:ok, socket}
end
