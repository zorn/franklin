defmodule FranklinWeb.Admin.UserLoginLive do
  use FranklinWeb, :admin_live_view

  def render(assigns) do
    ~H"""
    <div class="mt-8 mb-4">
      <h1 class="text-center font-light">Sign in to Franklin</h1>

      <%!-- FIXME: Not sure why but when I try to customize this border color it never works. --%>
      <div class="mx-auto w-96">
        <.admin_flash_messages flash={@flash} />

        <div class="bg-gray-100 border rounded mt-4 px-4 pb-4">
          <.form
            :let={f}
            for={@form}
            id="login_form"
            action={~p"/admin/users/log_in"}
            phx-update="ignore"
          >
            <.text_input form={f} field={:email} is_form_group is_full_width />
            <.text_input form={f} field={:password} is_form_group is_full_width />
            <.button is_submit is_primary is_full_width>Sign in</.button>
          </.form>
        </div>
      </div>
    </div>

    <%!-- <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/admin/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/admin/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/admin/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div> --%>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    dbg(form)
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
