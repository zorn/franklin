defmodule FranklinWeb.Components.Button do
  use Phoenix.Component

  attr :label, :string,
    required: true,
    doc: "a string value that suggests what action will be performed by the button"

  @spec button(map()) :: Phoenix.LiveView.Rendered.t()
  def button(assigns) do
    ~H"""
    <button
      type="button"
      class={[
        shape(),
        background(),
        padding(),
        typography(),
        text(),
        ring()
      ]}
    >
      <%= @label %>
    </button>
    """
  end

  # "inline-flex items-center rounded-md",
  #       "border border-transparent bg-red-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"

  # "inline-flex items-center rounded-md",
  #       "border border-transparent shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"

  defp shape() do
    "rounded-md"
  end

  defp background() do
    "bg-red-600 hover:bg-red-700"
  end

  defp padding() do
    "px-4 py-2"
  end

  defp typography() do
    "font-medium"
  end

  defp text() do
    "text-white"
  end

  defp ring() do
    "ring-2 ring-offset-2 ring-red-600 hover:ring-red-700"
  end
end
