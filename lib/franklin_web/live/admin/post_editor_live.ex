defmodule FranklinWeb.Admin.PostEditorLive do
  use FranklinWeb, :live_view

  alias FranklinWeb.Admin.PostEditorLive.PostForm

  def mount(_params, _session, socket) do
    changeset = PostForm.changeset(%PostForm{}, %{})

    IO.inspect(changeset)

    socket
    |> assign(changeset: changeset)
    |> ok()
  end

  def handle_event("save_form", %{"form" => form_params}, socket) do
    IO.inspect(form_params, label: "save_form")
    {:noreply, socket}
  end

  def handle_event("change_form", %{"form" => form_params}, socket) do
    IO.inspect(form_params, label: "change_form")
    # TODO: Not sure WHY/HOW I need to implement this. The docs say:
    # The LiveView must implement the phx-change event and store the input values
    # as they arrive on change. This is important because, if an unrelated change
    # happens on the page, LiveView should re-render the inputs with their updated
    # values. Without phx-change, the inputs would otherwise be cleared.
    # Alternatively, you can use phx-update="ignore" on the form to discard any
    # updates.
    # https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Helpers.html#form/1
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <p>Hello post editor!</p>

    <.form let={f} for={@changeset} phx-change="change_form" phx-submit="save_form">

      <%= label f, :title %>
      <%= text_input f, :title %>
      <%= error_tag f, :title %>

      <%= label f, :published_at %>
      <%= text_input f, :published_at %>
      <%= error_tag f, :published_at %>

      <%= submit "Save" %>

    </.form>
    """
  end

  defp ok(socket), do: {:ok, socket}
end
