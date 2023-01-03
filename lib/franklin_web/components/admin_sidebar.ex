defmodule FranklinWeb.Components.AdminSidebar do
  use Phoenix.Component

  import FranklinWeb.Components.AdminSidebarButton

  attr :links, :list, required: true

  # TODO: We should allow the user of this component to define where the user currently is so we can highlight that part of the navigation differently.

  @spec admin_sidebar(map()) :: Phoenix.LiveView.Rendered.t()
  def admin_sidebar(assigns) do
    ~H"""
    <nav class="">
      <%= for {title, url, icon_name} <- @links do %>
        <.admin_sidebar_button title={title} url={url} icon_name={icon_name} active?={false} />
      <% end %>
    </nav>
    """
  end
end
