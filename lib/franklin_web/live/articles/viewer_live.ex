defmodule FranklinWeb.Articles.ViewerLive do
  @moduledoc """
  A live view that presents articles for reading to public visitors.
  """
  use FranklinWeb, :live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Phoenix.LiveView.Socket

  def mount(%{"id" => id}, _session, socket) do
    socket
    |> assign_article(id)
    |> assign_rendered_body()
    |> ok()
  end

  @spec assign_article(Socket.t(), String.t()) :: Socket.t()
  defp assign_article(socket, id) do
    assign(socket, article: Articles.get_article(id))
  end

  @spec assign_rendered_body(Socket.t()) :: Socket.t()
  defp assign_rendered_body(%{assigns: %{article: %Article{body: nil}}} = socket) do
    assign(socket, rendered_body: nil)
  end

  defp assign_rendered_body(%{assigns: %{article: %Article{body: body}}} = socket) do
    {:ok, html_doc, _deprecation_messages} = Earmark.as_html(body)
    assign(socket, rendered_body: html_doc)
  end

  def render(assigns) do
    ~H"""
    <div class="text-xl font-bold my-4">Public Article Viewer</div>

    <h1 id="article-headline" class="text-5xl font-bold my-8"><%= @article.title %></h1>

    <div id="article-body" class="prose lg:prose-xl">
      <%= raw(@rendered_body) %>
    </div>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
