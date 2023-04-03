defmodule FranklinWeb.Admin.UserSettingsLive do
  use FranklinWeb, :admin_live_view

  import FranklinWeb.CoreComponents, only: [input: 1]

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

        <hr />

        <.layout>
          <:main>
            <.form
              :let={f}
              for={@password_form}
              id="password_form"
              action={~p"/admin/users/log_in?_action=password_updated"}
              method="post"
              phx-change="validate_password"
              phx-submit="update_password"
              phx-trigger-action={@trigger_submit}
            >
              <.input
                field={@password_form[:email]}
                type="hidden"
                id="hidden_user_email"
                value={@current_email}
              />
              <.form_group form={f} field={:password} label="New password">
                <.text_input form={f} field={:password} type="password" />
              </.form_group>
              <.form_group form={f} field={:password_confirmation} label="Confirm new password">
                <.text_input form={f} field={:password_confirmation} type="password" />
              </.form_group>
              <.form_group form={f} field={:current_password} label="Current password">
                <.text_input form={f} field={:current_password} type="password" />
              </.form_group>
              <.button is_submit phx-disable-with="Changing...">
                Change password
              </.button>
            </.form>
          </:main>
          <:sidebar>
            <h2>Change Password</h2>
            <p>Keep it secret. Keep it safe.</p>
          </:sidebar>
        </.layout>
      </div>
    </div>

    <%!--

    <div class="space-y-12 divide-y">

      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/admin/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <.input
            field={@password_form[:email]}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>
    </div> --%>
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
    password_changeset = Accounts.change_user_password(user)

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

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

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
