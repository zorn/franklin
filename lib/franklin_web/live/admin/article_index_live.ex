defmodule FranklinWeb.Admin.ArticleIndexLive do
  use FranklinWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(posts: [])
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <p>
      <.link href={~p"/"}>New Article</.link>
    </p>

    <%= for article <- @articles do %>
      <.link href={~p"/"}><%= article.title %></.link>
      published: <%= IO.inspect(article.published_at) %>
    <% end %>
    """
  end

  defp ok(socket), do: {:ok, socket}
end
