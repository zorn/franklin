defmodule FranklinWeb.Admin.Articles.ViewerLive do
  @moduledoc """
  Presents a detail view allowing an admin to preview the details of an
  `Article` entity.
  """

  use FranklinWeb, :admin_live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article

  def mount(params, _session, socket) do
    socket
    |> assign_article(params)
    |> assign_rendered_body()
    |> ok()
  end

  @spec assign_article(Socket.t(), map()) :: Socket.t()
  defp assign_article(socket, %{"id" => id}) do
    assign(socket, article: Articles.get_article(id))
  end

  @spec assign_rendered_body(Socket.t()) :: Socket.t()
  defp assign_rendered_body(%{assigns: %{article: %Article{body: body}}} = socket) do
    {:ok, html_doc, _deprecation_messages} = Earmark.as_html(body)
    assign(socket, rendered_body: html_doc)
  end

  def render(assigns) do
    ~H"""
    <div class="text-xl font-bold my-4">Article Viewer</div>

    <div>
      <%= link("Edit",
        to: Routes.admin_article_editor_path(FranklinWeb.Endpoint, :edit, @article.id)
      ) %>
    </div>

    <h1 id="article-headline" class="text-5xl font-bold my-8"><%= @article.title %></h1>

    <div id="article-body" class="prose lg:prose-xl">
      <%= raw(@rendered_body) %>
    </div>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
