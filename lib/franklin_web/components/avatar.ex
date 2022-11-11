defmodule FranklinWeb.Components.Avatar do
  use Phoenix.Component

  attr :src, :string, required: true
  attr :alt, :string, required: true

  @spec avatar(map()) :: Phoenix.LiveView.Rendered.t()
  def avatar(assigns) do
    ~H"""
    <img class="inline-block h-28 w-28 rounded-full" src={@src} alt={@alt} />
    """
  end
end
