defmodule FranklinWeb.Admin.Articles.IndexLive do
  use FranklinWeb, :admin_live_view

  alias Franklin.Articles
  alias Phoenix.LiveView.Socket

  def mount(_params, _session, socket) do
    socket
    |> assign(:articles, Articles.list_articles())
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <h2 class="text-xl font-bold my-4">Articles</h2>

    <p class="my-4">
      <%= link("New Article", to: Routes.admin_article_editor_path(FranklinWeb.Endpoint, :new)) %>
    </p>

    <.admin_simple_table rows={@articles}>
      <:column :let={article} label="Title">
        <%= link(article.title,
          to: Routes.admin_article_viewer_path(FranklinWeb.Endpoint, :show, article.id)
        ) %>
      </:column>
      <:column :let={article} label="Published At">
        <%= article.published_at %>
      </:column>
      <:column :let={article} label="Edit">
        <%= link("Edit",
          to: Routes.admin_article_editor_path(FranklinWeb.Endpoint, :edit, article.id)
        ) %>
      </:column>
    </.admin_simple_table>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
