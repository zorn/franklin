defmodule FranklinWeb.Admin.Articles.EditorLive do
  @moduledoc """
  Presents a form allowing an admin to create or edit a `Article` entity.
  """

  use FranklinWeb, :admin_live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Franklin.Articles.Slugs
  alias FranklinWeb.Admin.Articles.ArticleForm
  alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView.Socket

  def mount(params, _session, socket) do
    socket
    |> assign_article(params)
    |> assign_form()
    |> assign_form_changeset(%{})
    |> setup_subscription(params)
    |> ok()
  end

  @spec assign_article(Socket.t(), map()) :: Socket.t()
  defp assign_article(socket, %{"id" => id}) do
    case Articles.fetch_article(id) do
      {:ok, article} ->
        assign(socket, article: article)

      {:error, :article_not_found} ->
        raise Ecto.NoResultsError
        socket
    end
  end

  defp assign_article(socket, _) do
    assign(socket, article: %Article{})
  end

  @spec assign_form(Socket.t()) :: Socket.t()
  defp assign_form(%{assigns: %{article: article}} = socket) do
    assign(socket, form: ArticleForm.new(article))
  end

  @spec assign_form_changeset(Socket.t(), map()) :: Socket.t()
  defp assign_form_changeset(
         %{assigns: %{form: form, article: %Article{id: nil}}} = socket,
         form_params
       ) do
    # When not editing an existing `Article` we'll default to a `published_at` value of now.
    form_params = Map.put_new(form_params, "published_at", DateTime.utc_now())

    assign(socket, form_changeset: ArticleForm.changeset(form, form_params))
  end

  defp assign_form_changeset(%{assigns: %{form: form}} = socket, attrs) do
    assign(socket, form_changeset: ArticleForm.changeset(form, attrs))
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

  def handle_event("form_changed", %{"article_form" => form_params}, socket) do
    form_params = maybe_assign_autogenerated_slug(form_params)

    socket
    |> assign_form_changeset(form_params)
    |> noreply()
  end

  def handle_event("save_form", %{"article_form" => form_params}, socket) do
    form_params = maybe_assign_autogenerated_slug(form_params)

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
      title: form.title,
      slug: form.slug
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
      slug: form.slug,
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

  defp maybe_assign_autogenerated_slug(
         %{
           "title" => title,
           "published_at" => published_at,
           "slug_autogenerate" => "true"
         } = form_params
       ) do
    with {:ok, datetime, _} <- DateTime.from_iso8601(published_at),
         {:ok, slug} <- Slugs.generate_slug_for_title(title, datetime) do
      Map.put(form_params, "slug", slug)
    else
      _ -> form_params
    end
  end

  defp maybe_assign_autogenerated_slug(form_params), do: form_params

  # FIXME: We may in the future have a better way to observe events that should
  # trigger a redirect. See: https://github.com/zorn/franklin/discussions/62
  @redirect_triggers [
    :article_created,
    :article_title_updated,
    :article_body_updated,
    :article_slug_updated,
    :article_published_at_updated
  ]

  def handle_info({event, %{id: id}}, socket) when event in @redirect_triggers do
    # FIXME: This is a sus implementation because there are multiple messages
    # related to article creation and updates. It is questionable if we should
    # redirect after this event and not something else. An ultimate fix would
    # involve researching if other CQRS apps published attribute-specific
    # messages or something else. https://github.com/zorn/franklin/issues/21

    socket
    |> redirect(to: Routes.admin_article_viewer_path(FranklinWeb.Endpoint, :show, id))
    |> noreply()
  end

  def render(assigns) do
    ~H"""
    <h2 class="text-xl font-bold my-4">Article Editor</h2>

    <.form
      :let={f}
      for={@form_changeset}
      id="new-article"
      phx-submit="save_form"
      phx-change="form_changed"
    >
      <!-- Title -->
      <div class="my-4">
        <%= label(f, :title, class: "block text-sm font-medium text-gray-700") %>
        <div class="mt-1">
          <%= text_input(f, :title,
            class:
              "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          ) %>
        </div>
        <%= error_tag(f, :title, "mt-2 text-sm text-red-600") %>
      </div>
      <!-- Slug -->
      <div class="my-4">
        <%= label(f, :slug, class: "block text-sm font-medium text-gray-700") %>
        <div class="mt-1">
          <%= text_input(f, :slug,
            class:
              "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm",
            readonly: input_value(f, :slug_autogenerate)
          ) %>
        </div>
        <%= error_tag(f, :slug, "mt-2 text-sm text-red-600") %>

        <div class="relative flex items-start ml-2">
          <div class="flex h-5 items-center">
            <%= checkbox(f, :slug_autogenerate,
              class: "h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
            ) %>
          </div>
          <div class="ml-2 text-sm">
            <%= label(f, :slug_autogenerate, "Autogenerate slug from title.",
              class: "font-medium text-gray-700"
            ) %>
          </div>
        </div>
      </div>
      <!-- Published At -->
      <div class="my-4">
        <%= label(f, :published_at, class: "block text-sm font-medium text-gray-700") %>
        <div class="mt-1">
          <%= text_input(f, :published_at,
            class:
              "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          ) %>
        </div>
        <%= error_tag(f, :published_at, "mt-2 text-sm text-red-600") %>
      </div>
      <!-- Body -->
      <div class="my-4">
        <%= label(f, :body, class: "block text-sm font-medium text-gray-700") %>
        <div class="mt-1">
          <%= textarea(f, :body,
            rows: 12,
            class:
              "block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
          ) %>
        </div>
        <%= error_tag(f, :body, "mt-2 text-sm text-red-600") %>
      </div>

      <%= submit("Save",
        class:
          "inline-flex items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
      ) %>
    </.form>
    """
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}

  @spec noreply(Socket.t()) :: {:noreply, Socket.t()}
  defp noreply(socket), do: {:noreply, socket}
end
