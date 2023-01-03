defmodule FranklinWeb.Admin.ArticleIndexLive do
  use FranklinWeb, :live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(posts: [])
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <p><%= link("New Article", to: "/") %></p>

    <%= for article <- @articles do %>
      <p><%= link(article.title, to: "/") %> published: <%= IO.inspect(article.published_at) %></p>
    <% end %>
    """
  end

  defp ok(socket), do: {:ok, socket}
end
