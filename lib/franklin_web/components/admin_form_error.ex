defmodule FranklinWeb.Components.AdminFormError do
  use Phoenix.Component

  def admin_form_error(assigns) do
    ~H"""
    <p class="mt-2 text-sm text-red-600" id="email-error">
      Your password must be less than 4 characters.
    </p>
    """
  end
end
