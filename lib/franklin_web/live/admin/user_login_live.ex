defmodule FranklinWeb.Admin.UserLoginLive do
  use FranklinWeb, :admin_live_view

  def render(assigns) do
    ~H"""
    <div class="mt-8 mb-4">
      <div class="mx-auto w-96">
        <h1 class="text-center font-light mb-4">Sign in to Franklin</h1>

        <.admin_flash_messages flash={@flash} />

        <%!-- FIXME: When I try to customize this border color it never works. --%>
        <div class="bg-gray-100 border rounded mt-4 px-4 pb-4">
          <.form :let={f} for={@form} id="login_form" action={~p"/admin/sign-in"} phx-update="ignore">
            <.text_input form={f} field={:email} is_form_group is_full_width />
            <.text_input form={f} field={:password} type="password" is_form_group is_full_width />

            <.form_group form={f} field={:remember_me} is_hide_label>
              <.checkbox form={f} field={:remember_me}>
                <:label>Keep me signed in</:label>
              </.checkbox>
            </.form_group>

            <.button is_submit is_primary is_full_width>Sign in</.button>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    dbg(form)
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
