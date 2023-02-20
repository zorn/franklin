defmodule FranklinWeb.Articles.ViewerLive do
  @moduledoc """
  A live view that presents articles for reading to public visitors.
  """
  use FranklinWeb, :live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Phoenix.LiveView.Socket

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug}, _session, socket) do
    socket
    |> assign_article(slug)
    |> assign_rendered_body()
    |> ok()
  end

  @spec assign_article(Socket.t(), String.t()) :: Socket.t()
  defp assign_article(socket, slug) do
    dbg(slug)
    slug = Enum.join(slug, "/") |> Kernel.<>("/")
    dbg(slug)

    case Articles.get_article_by_slug(slug) do
      nil ->
        raise Ecto.NoResultsError
        socket

      article ->
        assign(socket, article: article)
    end
  end

  @spec assign_rendered_body(Socket.t()) :: Socket.t()
  defp assign_rendered_body(%{assigns: %{article: %Article{body: nil}}} = socket) do
    assign(socket, rendered_body: nil)
  end

  defp assign_rendered_body(%{assigns: %{article: %Article{body: body}}} = socket) do
    {:ok, html_doc, _deprecation_messages} = Earmark.as_html(body)
    assign(socket, rendered_body: html_doc)
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1 id="article-headline" class="text-4xl font-bold my-8"><%= @article.title %></h1>

    <div id="article-body" class="prose lg:prose-xl">
      <%= raw(@rendered_body) %>
    </div>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
