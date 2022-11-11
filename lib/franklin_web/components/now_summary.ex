defmodule FranklinWeb.Components.NowSummary do
  use Phoenix.Component

  @spec now_summary(map()) :: Phoenix.LiveView.Rendered.t()
  def now_summary(assigns) do
    ~H"""
    <section>
      <h2 class="font-bold text-2xl mb-2">Current Focus</h2>

      <p class="prose max-w-none mb-2">
        Part-time Elixir/Phoenix consulting (leading a small team maintaining a platform in the health case space); Working through Testing Elixir as part of the Elixir Book Club; Hacking on Franklin (the Phoenix app powering this blog; Playing through Final Fantasy VI Pixel Remaster on my new Steam Deck.
      </p>

      <div class="italic">
        For more detail see my <a class="underline" href="/now">/now</a> page.
      </div>
    </section>
    """
  end
end
