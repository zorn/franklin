defmodule FranklinWeb.Admin.PostEditorLive do
  @moduledoc """
  Presents a form to an admin allowing them to create or edit a `Post` entity.
  """

  use FranklinWeb, :live_view

  import Ecto.Changeset

  alias Franklin.Posts
  alias Franklin.Posts.Projections.Post
  alias FranklinWeb.Admin.PostEditorLive.Form

  @type socket :: Phoenix.LiveView.Socket.t()

  defguard is_not_nil(x) when not is_nil(x)

  @doc """
  Mounts and configures the LiveView appropriately depending on if we are
  editing an existing `Post` or creating a new one.
  """
  def mount(%{"id" => id} = _params, _session, socket) do
    socket
    |> assign(post: Posts.get_post(id))
    |> assign_form()
    |> assign_form_changeset()
    |> setup_subscription(id)
    |> ok()
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(post: %Post{})
    |> assign_form()
    |> assign_form_changeset()
    |> setup_subscription(Ecto.UUID.generate())
    |> ok()
  end

  @spec assign_form(socket) :: socket
  defp assign_form(%{assigns: %{post: post}} = socket) do
    # FIXME: Maybe rename this to be `form_data` to help express the noun more and differentiate from the form/1 test helper?
    # `form` represents the independent value type of the web form. It will
    # default to the current attributes of the `post`.
    assign(socket, form: %Form{title: post.title, published_at: post.published_at})
  end

  @spec assign_form_changeset(socket) :: socket
  defp assign_form_changeset(%{assigns: %{form: form, post: %Post{id: nil}}} = socket) do
    # When not editing an existing `Post` we'll default to a `published_at` value of now.
    assign(socket, form_changeset: Form.changeset(form, %{published_at: DateTime.utc_now()}))
  end

  defp assign_form_changeset(%{assigns: %{form: form}} = socket) do
    assign(socket, form_changeset: Form.changeset(form, %{}))
  end

  @spec setup_subscription(socket, Ecto.UUID.t()) :: socket
  defp setup_subscription(socket, id) do
    Posts.subscribe(id)
    # `subscription_id` represents the id of the `Post` being edited. If the
    # editor is current being used to create a new `Post` than it will hold the
    # uuid value that will be assigned to the new `Post` upon submit.
    assign(socket, subscription_id: id)
  end

  def handle_event("save_form", %{"form" => form_params}, socket) do
    case apply_action(Form.changeset(socket.assigns.form, form_params), :validate) do
      {:ok, %Form{} = validated_form} ->
        do_save(socket.assigns.post, validated_form, socket)

      {:error, form_changeset} ->
        socket
        |> assign(form_changeset: form_changeset)
        |> noreply()
    end
  end

  @spec do_save(Post.t(), Form.t(), socket) :: {:noreply, socket}
  defp do_save(%Post{id: nil}, form, socket) do
    # Run save action to create a new post.
    create_attrs = %{
      id: socket.assigns.subscription_id,
      published_at: form.published_at,
      title: form.title
    }

    case Posts.create_post(create_attrs) do
      {:ok, _post_id} ->
        # FIXME: Enter a state where the form is still disabled while we wait for redirect.
        {:noreply, socket}

      {:error, _errors} ->
        # FIXME: Present flash-style error with generic failure message (since
        # the user likely can not recover at this point).
        {:noreply, put_flash(socket, :error, "Could not create post.")}
    end
  end

  defp do_save(%Post{id: id} = post, form, socket) when is_not_nil(id) do
    # Run save action to update an existing post.
    update_attrs = %{
      published_at: form.published_at,
      title: form.title
    }

    case Posts.update_post(post, update_attrs) do
      {:ok, _post_id} ->
        # FIXME: Enter a state where the form is still disabled while we wait for redirect.
        {:noreply, socket}

      {:error, _errors} ->
        # FIXME: Present flash-style error with generic failure message (since
        # the user likely can not recover at this point).

        {:noreply, put_flash(socket, :error, "Could not save changes.")}
    end
  end

  def handle_info({:post_created, %{id: id}}, socket) do
    socket
    |> redirect(to: Routes.post_details_path(socket, :details, id))
    |> noreply()
  end

  def handle_info({:post_title_updated, %{id: id}}, socket) do
    # FIXME: This is a sus implementation because there are multiple messages
    # related to post updates. It is questionable if we should redirect after
    # this event and not something else. An ultimate fix would involve
    # researching if other CQRS apps published attribute-specific messages or
    # something else.
    socket
    |> redirect(to: Routes.post_details_path(socket, :details, id))
    |> noreply()
  end

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <.form let={f} for={@form_changeset} id="new-post" phx-submit="save_form">

      <%= label f, :title %>
      <%= text_input f, :title %>
      <%= error_tag f, :title %>

      <%= label f, :published_at %>
      <%= datetime_local_input f, :published_at %>
      <%= error_tag f, :published_at %>

      <%= submit "Save" %>

    </.form>
    """
  end

  @spec ok(socket) :: {:ok, socket}
  defp ok(socket), do: {:ok, socket}

  @spec noreply(socket) :: {:noreply, socket}
  defp noreply(socket), do: {:noreply, socket}
end
