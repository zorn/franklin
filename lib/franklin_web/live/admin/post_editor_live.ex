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

  def mount(params, _session, socket) do
    socket
    |> assign_post(params)
    |> assign_form()
    |> assign_form_changeset()
    |> setup_subscription(params)
    |> ok()
  end

  defp assign_post(socket, %{"id" => id}) do
    assign(socket, post: Posts.get_post(id))
  end

  defp assign_post(socket, _) do
    assign(socket, post: %Post{})
  end

  @spec assign_form(socket) :: socket
  defp assign_form(%{assigns: %{post: post}} = socket) do
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

  # `subscription_id` represents the id of the post we are current editing or
  # the id of the post we are attempting to create.
  @spec setup_subscription(socket, map() | nil) :: socket
  defp setup_subscription(socket, %{"id" => id}) do
    Posts.subscribe(id)
    assign(socket, subscription_id: id)
  end

  defp setup_subscription(socket, _) do
    id = Ecto.UUID.generate()
    Posts.subscribe(id)
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
  defp do_save(%Post{id: nil}, form, %{assigns: %{subscription_id: subscription_id}} = socket) do
    create_attrs = %{
      id: subscription_id,
      published_at: form.published_at,
      title: form.title
    }

    case Posts.create_post(create_attrs) do
      {:ok, ^subscription_id} ->
        # FIXME: Enter a state where the form is still disabled while we wait for redirect.
        # https://github.com/zorn/franklin/issues/20
        {:noreply, socket}

      {:error, _errors} ->
        # FIXME: Present flash-style error with generic failure message (since
        # the user likely can not recover at this point).
        {:noreply, put_flash(socket, :error, "Could not create post.")}
    end
  end

  defp do_save(%Post{id: id} = post, form, socket) do
    update_attrs = %{
      published_at: form.published_at,
      title: form.title
    }

    case Posts.update_post(post, update_attrs) do
      {:ok, ^id} ->
        # FIXME: Enter a state where the form is still disabled while we wait for redirect.
        # https://github.com/zorn/franklin/issues/20
        {:noreply, socket}

      {:error, _errors} ->
        # FIXME: Present flash-style error with generic failure message (since
        # the user likely can not recover at this point).
        {:noreply, put_flash(socket, :error, "Could not save changes.")}
    end
  end

  def handle_info({:post_created, %{id: id}}, socket) do
    socket
    |> redirect(to: path(socket, FranklinWeb.Router, ~p"/admin/posts/#{id}"))
    |> noreply()
  end

  def handle_info({:post_title_updated, %{id: id}}, socket) do
    # FIXME: This is a sus implementation because there are multiple messages
    # related to post updates. It is questionable if we should redirect after
    # this event and not something else. An ultimate fix would involve
    # researching if other CQRS apps published attribute-specific messages or
    # something else.
    # https://github.com/zorn/franklin/issues/21
    socket
    |> redirect(to: url(~p"/admin/posts/#{id}"))
    |> noreply()
  end

  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <.form :let={f} for={@form_changeset} id="new-post" phx-submit="save_form">
      <%= Phoenix.HTML.Form.label(f, :title) %>
      <%= Phoenix.HTML.Form.text_input(f, :title) %>
      <%= error_tag(f, :title) %>

      <%= Phoenix.HTML.Form.label(f, :published_at) %>
      <%= Phoenix.HTML.Form.datetime_local_input(f, :published_at) %>
      <%= error_tag(f, :published_at) %>

      <%= Phoenix.HTML.Form.submit("Save") %>
    </.form>
    """
  end

  @spec ok(socket) :: {:ok, socket}
  defp ok(socket), do: {:ok, socket}

  @spec noreply(socket) :: {:noreply, socket}
  defp noreply(socket), do: {:noreply, socket}
end
