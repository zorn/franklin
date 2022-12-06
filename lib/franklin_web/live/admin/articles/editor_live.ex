defmodule FranklinWeb.Admin.Articles.EditorLive do
  use FranklinWeb, :admin_live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Phoenix.LiveView.Socket

  def mount(params, _session, socket) do
    socket
    |> assign_article(params)
    |> ok()
  end

  defp assign_article(socket, %{"id" => id}) do
    assign(socket, article: Articles.get_article(id))
  end

  defp assign_article(socket, _) do
    assign(socket, article: %Article{})
  end

  def render(assigns) do
    ~H"""
    <h2 class="text-xl font-bold my-4">Article Editor</h2>

    <%= @article.title %>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}

  @spec noreply(Socket.t()) :: {:noreply, Socket.t()}
  defp noreply(socket), do: {:noreply, socket}
end
