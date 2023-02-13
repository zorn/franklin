defmodule FranklinWeb.HomeLive do
  @moduledoc """
  The composition view for the home page.

  A composition view is responsible for the assembly and presentation of the
  components. Real talk: a composition view is responsible for determining the
  margins and paddings of the presented elements of the page.
  """

  use FranklinWeb, :live_view

  alias Franklin.Articles
  alias Phoenix.LiveView.Socket

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket
    |> assign(:recent_articles, Articles.list_articles(%{limit: 3}))
    |> ok()
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <main>
      <section class="prose hover:prose-a:text-blue-700 max-w-none mb-6">
        <p>
          My name is <strong>Mike Zornek</strong>
          and I am a developer and teacher living in the suburbs of Philadelphia, PA. I am a computer programmer, writer, video editor, player of video games (lots of retro and RPG-type games) and spectator to baseball games; go Phillies!
        </p>

        <p>
          My current programming focus is <a href="https://elixir-lang.org/">Elixir</a>, <a href="https://www.phoenixframework.org/">Phoenix</a>, and <a href="https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html">LiveView</a>. I work as a
          <a href="/for-hire">freelance contractor</a>
          alongside my own <a href="/now">personal projects</a>.
        </p>
      </section>

      <section>
        <h1 class="font-bold text-2xl mb-2">Recent Additions</h1>

        <ul class="ml-8">
          <%= for article <- @recent_articles do %>
            <li class="mb-2 list-disc">
              <%= live_redirect(article.title,
                to: Routes.article_viewer_path(FranklinWeb.Endpoint, :show, article.id),
                class: "underline hover:text-blue-700"
              ) %>
            </li>
          <% end %>
        </ul>
      </section>
    </main>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
