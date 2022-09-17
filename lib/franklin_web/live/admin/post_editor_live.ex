defmodule FranklinWeb.Admin.PostEditorLive do
  use FranklinWeb, :live_view

  import Ecto.Changeset

  alias Franklin.Posts
  alias FranklinWeb.Admin.PostEditorLive.PostForm
  alias Franklin.Posts.Projections.Post

  defguard is_not_nil(x) when not is_nil(x)

  def mount(%{"id" => id} = _params, _session, socket) do
    post = Posts.get_post(id)
    Posts.subscribe(post.id)

    # FIXME: We might want to save this "form" value on the socket for a more
    # consistent changeset creation code late.
    post_form = %PostForm{title: post.title, published_at: post.published_at}

    socket
    |> assign(post: post)
    |> assign(changeset: PostForm.changeset(post_form, %{}))
    |> ok()
  end

  def mount(_params, _session, socket) do
    new_post_uuid = Ecto.UUID.generate()
    Posts.subscribe(new_post_uuid)

    changeset =
      PostForm.changeset(%PostForm{}, %{
        id: new_post_uuid,
        published_at: DateTime.utc_now()
      })

    socket
    |> assign(new_post_uuid: new_post_uuid)
    |> assign(changeset: changeset)
    |> ok()
  end

  def handle_event("save_form", %{"post_form" => form_params}, socket) do
    IO.inspect(form_params, label: "save_form")

    post = Map.get(socket.assigns, :post, %Post{})

    case apply_action(PostForm.changeset(%PostForm{}, form_params), :validate) do
      {:error, changeset} ->
        socket
        |> assign(changeset: changeset)
        |> noreply()

      {:ok, validated_params} ->
        save_post(post, validated_params, socket)
    end
  end

  # Not sure I like how repetitive this code is between create and update.
  defp save_post(%Post{id: nil} = _post, validated_params, socket) do
    attrs = %{
      id: socket.assigns.new_post_uuid,
      published_at: validated_params.published_at,
      title: validated_params.title
    }

    case Posts.create_post(attrs) do
      {:ok, _post_id} ->
        # FIXME: Enter a state where the form is frozen, and we are waiting for the redirect?
        {:noreply, socket}

      {:error, _errors} ->
        # ideally any validation errors were captured by the form-specific changeset. if the command failed for validation or other reasons maybe we just display that in a generic flash error message?

        {:noreply, socket}
    end
  end

  defp save_post(%Post{id: id} = post, validated_params, socket) when is_not_nil(id) do
    attrs = %{
      published_at: validated_params.published_at,
      title: validated_params.title
    }

    case Posts.update_post(post, attrs) do
      {:ok, _post_id} ->
        # FIXME: Enter a state where the form is frozen, and we are waiting for the redirect?
        {:noreply, socket}

      {:error, errors} ->
        # ideally any validation errors were captured by the form-specific changeset. if the command failed for validation or other reasons maybe we just display that in a generic flash error message?

        {:noreply, socket}
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

  def render(assigns) do
    ~H"""
    <.form let={f} for={@changeset} phx-submit="save_form">

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

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}
end
