defmodule FranklinWeb.Admin.IndexLive do
  use FranklinWeb, :admin_live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <p id="welcome-message">Welcome to the Admin area.</p>

    <.button label="hello" />
    """
  end
end
