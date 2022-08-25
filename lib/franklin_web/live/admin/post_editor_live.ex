defmodule FranklinWeb.Admin.PostEditorLive do
  use FranklinWeb, :live_view

  import Ecto.Changeset

  alias Franklin.Posts
  alias FranklinWeb.Admin.PostEditorLive.PostForm

  def mount(_params, _session, socket) do
    changeset =
      PostForm.changeset(%PostForm{}, %{"title" => "hello world", "published_at" => "someday"})

    IO.inspect(changeset)

    socket
    |> assign(changeset: changeset)
    |> ok()
  end

  def handle_event("save_form", %{"post_form" => form_params}, socket) do
    IO.inspect(form_params, label: "save_form")

    case apply_action(PostForm.changeset(%PostForm{}, form_params), :validate) do
      {:error, changeset} ->
        IO.inspect(changeset, label: "changeset")

        socket
        |> assign(changeset: changeset)
        |> noreply()

      {:ok, changeset} ->
        # Make the `CreatePost` command, dispatch it, then wait for an event to signal it is projected, then do a redirect.
        # I don't think we want to make a command here.
        # Commands should be a hidden implimentation of the core
        # We can't send the core this changeset though since that is a UI detail
        uuid = Ecto.UUID.generate()
        title = nil

        # for now we'll do a raw datetime value and later we will parse the string into a datetime
        published_at = DateTime.utc_now()
        # published_at = Ecto.Changeset.fetch_field!(changeset, :published_at)

        case Posts.create_post(uuid, title, published_at) do
          {:ok, uuid} ->
            # Start delayed listening for post_created event and then redirect to detail page

            {:noreply, socket}

          {:error, reason} ->
            # ideally any validation errors were captured by the form-specific changeset. if the command failed for validation or other reasons maybe we just display that in a generic flash error message?

            {:noreply, socket}
        end
    end
  end

  def handle_event("change_form", %{"post_form" => form_params}, socket) do
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
  defp noreply(socket), do: {:noreply, socket}
end
