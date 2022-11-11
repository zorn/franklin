defmodule FranklinWeb.Components.SocialCard do
  use Phoenix.Component

  attr :content, :string, required: true
  attr :url, :string, required: true
  attr :mastodon_url, :string, required: true

  @spec social_card(map()) :: Phoenix.LiveView.Rendered.t()
  def social_card(assigns) do
    ~H"""
    <section class="prose mb-8">
      <%= Phoenix.HTML.raw(@content) %>
    </section>
    """
  end
end
