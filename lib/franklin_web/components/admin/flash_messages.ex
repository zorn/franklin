defmodule FranklinWeb.Components.Admin.FlashMessages do
  @moduledoc """
  Renders a list of styled flash messages.
  """

  use Phoenix.Component
  use PrimerLive

  attr :flash, :map, required: true

  def admin_flash_messages(assigns) do
    ~H"""
    <%= for type <- expected_flash_types() do %>
      <%= if has_flash_message_for_type(@flash, type) do %>
        <div class="my-3">
          <.alert state={to_string(type)}>
            <.octicon name={icon_name(type)} /> <%= Phoenix.Flash.get(@flash, type) %>
            <%!-- TODO: It would be nice to have a close button here,
            but to do so I would need to have it send back a "close"
            event to the LiveView to then clear the flash. I can do
            that but will do it later. --%>
            <%!-- <.button class="flash-close">
              <.octicon name="x-16" />
            </.button> --%>
          </.alert>
        </div>
      <% end %>
    <% end %>
    """
  end

  defp has_flash_message_for_type(flash, type) do
    case Phoenix.Flash.get(flash, type) do
      nil -> false
      "" -> false
      _ -> true
    end
  end

  defp expected_flash_types() do
    [:info, :success, :warning, :error]
  end

  defp icon_name(:info), do: "info-16"
  defp icon_name(:success), do: "check-16"
  defp icon_name(:warning), do: "alert-16"
  defp icon_name(:error), do: "stop-16"
  defp icon_name(_), do: nil
end
