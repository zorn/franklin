defmodule FranklinWeb.Articles.IndexLive do
  @moduledoc """
  Presents a list of links, showing the full blog article archive.
  """
  use FranklinWeb, :live_view

  alias Franklin.Articles
  alias Phoenix.LiveView.Socket

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:all_articles, Articles.list_articles(%{published_only: true}))
    |> ok()
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <main>
      <ul class="ml-8">
        <%= for article <- @all_articles do %>
          <li class="mb-2 list-disc">
            <.link
              class="underline hover:text-blue-700"
              navigate={~p"/articles/#{String.split(article.slug, "/")}"}
            >
              <%= article.title %>
            </.link>
            &bull;
            <span class="text-gray-400">
              <%= Calendar.strftime(article.published_at, "%b %d %Y") %>
            </span>
          </li>
        <% end %>
      </ul>
    </main>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
