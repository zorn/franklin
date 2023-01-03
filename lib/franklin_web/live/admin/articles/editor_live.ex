defmodule FranklinWeb.Admin.Articles.EditorLive do
  @moduledoc """
  Presents a form allowing an admin to create or edit a `Article` entity.
  """

  use FranklinWeb, :admin_live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Phoenix.LiveView.Socket

  alias FranklinWeb.Admin.Articles.ArticleForm
  alias Phoenix.LiveView.Socket

  def mount(params, _session, socket) do
    socket
    |> assign_article(params)
    |> assign_form()
    |> assign_form_changeset()
    |> setup_subscription(params)
    |> ok()
  end

  @spec assign_article(Socket.t(), map()) :: Socket.t()
  defp assign_article(socket, %{"id" => id}) do
    assign(socket, article: Articles.get_article(id))
  end

  defp assign_article(socket, _) do
    assign(socket, article: %Article{})
  end

  @spec assign_form(Socket.t()) :: Socket.t()
  defp assign_form(%{assigns: %{article: article}} = socket) do
    assign(socket, form: ArticleForm.new(article))
  end

  @spec assign_form_changeset(Socket.t()) :: Socket.t()
  defp assign_form_changeset(%{assigns: %{form: form, article: %Article{id: nil}}} = socket) do
    # When not editing an existing `Article` we'll default to a `published_at` value of now.
    assign(socket,
      form_changeset: ArticleForm.changeset(form, %{published_at: DateTime.utc_now()})
    )
  end

  defp assign_form_changeset(%{assigns: %{form: form}} = socket) do
    assign(socket, form_changeset: ArticleForm.changeset(form, %{}))
  end

  @spec setup_subscription(Socket.t(), map() | nil) :: Socket.t()
  defp setup_subscription(socket, %{"id" => id}) do
    Articles.subscribe(id)
    # `subscription_id` represents the id of the `Article` we are current editing or
    # the id of the article we are attempting to create.
    assign(socket, subscription_id: id)
  end

  defp setup_subscription(socket, _) do
    id = Ecto.UUID.generate()
    Articles.subscribe(id)
    assign(socket, subscription_id: id)
  end

  def handle_event("save_form", %{"article_form" => form_params}, socket) do
    changeset = ArticleForm.changeset(socket.assigns.form, form_params)

    case Ecto.Changeset.apply_action(changeset, :validate) do
      {:ok, %ArticleForm{} = validated_form} ->
        do_save(socket.assigns.article, validated_form, socket)

      {:error, form_changeset} ->
        socket
        |> assign(form_changeset: form_changeset)
        |> noreply()
    end
  end

  @spec do_save(Article.t(), ArticleForm.t(), Socket.t()) :: {:noreply, Socket.t()}
  defp do_save(%Article{id: nil}, form, %{assigns: %{subscription_id: subscription_id}} = socket) do
    create_attrs = %{
      id: subscription_id,
      body: form.body,
      published_at: form.published_at,
      title: form.title
    }

    case Articles.create_article(create_attrs) do
      {:ok, ^subscription_id} ->
        # FIXME: Enter a state where the form is still disabled while we wait for redirect.
        # https://github.com/zorn/franklin/issues/20
        {:noreply, socket}

      {:error, _errors} ->
        # FIXME: Present flash-style error with generic failure message (since
        # the user likely can not recover at this point).
        {:noreply, put_flash(socket, :error, "Could not create article.")}
    end
  end

  defp do_save(%Article{id: id} = article, form, socket) do
    update_attrs = %{
      published_at: form.published_at,
      title: form.title,
      body: form.body
    }

    case Articles.update_article(article, update_attrs) do
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

  def render(assigns) do
    ~H"""
    <h2 class="text-xl font-bold my-4">Article Editor</h2>

    <.form :let={f} for={@form_changeset} id="new-post" phx-submit="save_form">
      <.admin_form_input field={{f, :title}} type="text" label="Title" />

      <%= label(f, :title) %>
      <%= text_input(f, :title) %>
      <%= error_tag(f, :title) %>

      <%= label(f, :body) %>
      <%= text_input(f, :body) %>
      <%= error_tag(f, :body) %>

      <%= label(f, :published_at) %>
      <%= datetime_local_input(f, :published_at) %>
      <%= error_tag(f, :published_at) %>

      <%= submit("Save") %>
    </.form>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}

  @spec noreply(Socket.t()) :: {:noreply, Socket.t()}
  defp noreply(socket), do: {:noreply, socket}
end
