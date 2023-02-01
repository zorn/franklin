defmodule FranklinWeb.HomeLive do
  @moduledoc """
  The composition view for the home page.

  A composition view is responsible for the assembly and presentation of the components. Real talk: a composition view is responsible for determining the margins and paddings of the presented elements of the page.

  TODO: It would be neat to turn on these layout helper bg colors with a boolean.
  """

  use FranklinWeb, :live_view

  alias Franklin.Articles
  alias Phoenix.LiveView.Socket

  def mount(_params, _session, socket) do
    socket
    |> assign(:articles, Articles.list_articles(%{limit: 3}))
    |> ok()
  end

  def render(assigns) do
    ~H"""
    <div id="layout-grid" class="lg:grid grid-cols-12 grid-rows-1 py-10">
      <div id="side-nav" class="bg-red-500 col-span-3 px-6">
        <header class="bg-pink-500">
          <.avatar src="/images/zorn_square.png" alt="Mike Zornek's avatar image." />
          <.name_plate
            name="Mike Zornek"
            title="Developer and Teacher"
            bio="Specializing in Elixir, Phoenix and LiveView."
          />
        </header>
        <.navigation links={[
          {"Home", "/"},
          {"Blog", "/"},
          {"Now", "/"},
          {"Values", "/"},
          {"For Hire", "/"},
          {"Follow", "/"},
          {"Contact", "/"}
        ]} />
      </div>

      <main class="bg-orange-500 col-span-6 px-6">
        <section class="prose max-w-none mb-6">
          My name is Mike Zornek and I am a developer and teacher living in the suburbs of Philadelphia. My programming focus is currently <a href="https://elixir-lang.org/">Elixir</a>, <a href="https://www.phoenixframework.org/">Phoenix</a>, and <a href="https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html">LiveView</a>. When I'm not programming I enjoy watching baseball (Go Phillies!) and playing video games (mostly role playing games and relaxing simulations).
        </section>

        <div class="mb-6">
          <.now_summary />
        </div>

        <section>
          <h1 class="font-bold text-2xl mb-2">Recent Content</h1>

          <%= for article <- @articles do %>
            <.content_preview
              title={article.title}
              summary={article.title}
              url={Routes.article_viewer_path(FranklinWeb.Endpoint, :show, article.id)}
              thumbnail_src="/images/we-are-fine.jpg"
              thumbnail_alt_text="StarWars Meme: WHEN PROJECT MANAGER ASKING FOR UPDATE AT STANDUP CALL WE ARE FINE WE ARE ALL FINE NOW. HOW ARE YOU?"
              published_on={article.published_at}
            />
          <% end %>
        </section>

        <footer class="bg-blue-500">
          <div class="text-right">Jump to Top</div>
        </footer>
      </main>

      <section class="bg-teal-400 col-span-3 px-6">
        <h1 class="font-bold text-2xl mb-2">Recent Social Posts</h1>

        <.social_card
          content="
          <p>
            😢 When a loved one dies, it sure does highlight the inhuman nature of software memory prompts and suggestions.
          </p>

          <p>It hits me hard and is more common than I would have thought.</p>

          <p>
            My answer is just to turn as much stuff off as I can, but this isn't even an option for some things.
          </p>
          "
          url="/"
          mastodon_url="/"
        />

        <.social_card
          content="
          <p>✅ Today&#39;s goals:</p>
          <ul>
            <li>Pay some IRS bills.</li>
            <li>A bit of client sprint shaping/pr review.</li>
            <li>Watch some videos from GitHub Universe.</li>
            <li>Continue crafting components for Franklin.</li>
            <li>Read Chapter 2 of Testing Elixir.</li>
          </ul>
          "
          url="/"
          mastodon_url="/"
        />

        <.social_card content={some_content()} url="/" mastodon_url="/" />
      </section>
    </div>
    """
  end

  defp some_content() do
    ~s(
          <p>✏️ My Standup Format</p>
          <p>
            There is an async standup format I've been using for over a year now, and since it seems to be sticking, I figured I'd take a moment to share it and explain why I like it.
          </p>
          <p>
            <a href="https://mikezornek.com/posts/2022/11/my-standup-format/\">
              https://mikezornek.com/posts/2022/11/my-standup-format/
            </a>
          </p>
        )
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
