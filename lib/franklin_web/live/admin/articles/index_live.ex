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
      <.link href={~p"/admin/articles/new"}>New Article</.link>
    </p>

    <.admin_simple_table rows={@articles}>
      <:column :let={article} label="Title">
        <.link href={~p"/admin/articles/#{article.id}"}><%= article.title %></.link>
      </:column>
      <:column :let={article} label="Published At">
        <%= article.published_at %>
      </:column>
      <:column :let={article} label="Edit">
        <.link href={~p"/admin/articles/editor/#{article.id}"}>Edit</.link>
      </:column>
    </.admin_simple_table>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
