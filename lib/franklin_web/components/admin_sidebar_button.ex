defmodule FranklinWeb.Components.AdminSidebarButton do
  use Phoenix.Component

  # FIXME: Currently we are not using active? but want to in the future
  attr :active?, :boolean, default: false
  attr :icon_name, :string, required: true
  attr :title, :string, required: true
  attr :url, :string, required: true

  @spec admin_sidebar_button(map()) :: Phoenix.LiveView.Rendered.t()
  def admin_sidebar_button(assigns) do
    ~H"""
    <a
      href={@url}
      class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md"
    >
      <svg
        class="text-gray-400 group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6"
        xmlns="http://www.w3.org/2000/svg"
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
        aria-hidden="true"
      >
        <path stroke-linecap="round" stroke-linejoin="round" d={icon(@icon_name)} />
      </svg>
      <%= @title %>
    </a>
    """
  end

  defp icon("articles") do
    "M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z"
  end

  defp icon("rocket") do
    "M15.59 14.37a6 6 0 01-5.84 7.38v-4.8m5.84-2.58a14.98 14.98 0 006.16-12.12A14.98 14.98 0 009.631 8.41m5.96 5.96a14.926 14.926 0 01-5.841 2.58m-.119-8.54a6 6 0 00-7.381 5.84h4.8m2.581-5.84a14.927 14.927 0 00-2.58 5.84m2.699 2.7c-.103.021-.207.041-.311.06a15.09 15.09 0 01-2.448-2.448 14.9 14.9 0 01.06-.312m-2.24 2.39a4.493 4.493 0 00-1.757 4.306 4.493 4.493 0 004.306-1.758M16.5 9a1.5 1.5 0 11-3 0 1.5 1.5 0 013 0z"
  end

  defp icon(_) do
    "M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3"
  end
end
