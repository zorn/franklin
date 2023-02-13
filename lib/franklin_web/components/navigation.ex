defmodule FranklinWeb.Components.Navigation do
  use Phoenix.Component

  attr :links, :list, required: true

  @spec navigation(map()) :: Phoenix.LiveView.Rendered.t()
  def navigation(assigns) do
    ~H"""
    <nav class="">
      <ul class="inline-flex items-center">
        <%= for {title, target} <- @links do %>
          <li class="text-lg font-bold pr-4 hover:underline hover:text-blue-700">
            <%= live_redirect(title, to: target) %>
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
