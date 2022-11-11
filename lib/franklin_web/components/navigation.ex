defmodule FranklinWeb.Components.Navigation do
  use Phoenix.Component

  attr :links, :list, required: true

  @spec navigation(map()) :: Phoenix.LiveView.Rendered.t()
  def navigation(assigns) do
    ~H"""
    <nav class="bg-yellow-500">
      <ul>
        <%= for {title, target} <- @links do %>
          <li><a href={target}><%= title %></a></li>
        <% end %>
      </ul>
    </nav>
    """
  end
end
