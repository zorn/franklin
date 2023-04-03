defmodule FranklinWeb.Admin.UserSettingsLive do
  use FranklinWeb, :admin_live_view

  alias Franklin.Accounts

  def render(assigns) do
    ~H"""
    <div class="mt-8 mb-4">
      <div class="max-w-screen-lg mx-auto">
        <h1 class="">Account Settings</h1>

        <hr />

        <.layout>
          <:main>
            <.admin_flash_messages flash={@flash} />

            <.form
              :let={f}
              class="mb-6"
              for={@email_form}
              id="email_form"
              phx-submit="update_email"
              phx-change="validate_email"
            >
              <.text_input form={f} field={:email} type="email" is_form_group />

              <.form_group form={f} field={:current_password} label="Current password">
                <.text_input
                  form={f}
                  field={:current_password}
                  type="password"
                  id="current_password_for_password"
                />
              </.form_group>

              <.button is_submit phx-disable-with="Changing...">
                Change email
              </.button>
            </.form>
          </:main>
          <:sidebar>
            <h2>Change Email</h2>
            <p>Sold to the highest bidder.</p>
          </:sidebar>
        </.layout>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/admin/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)

    socket =
      socket
      |> assign(:email_form_current_password, nil)
      |> assign(:email_form, to_form(email_changeset))

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => password} = user_params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    %{"current_password" => password} = user_params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/admin/users/settings/confirm_email/#{&1}")
        )

        info =
          "Pending change accepted. A link to confirm this email change has been sent to the new address."

        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
