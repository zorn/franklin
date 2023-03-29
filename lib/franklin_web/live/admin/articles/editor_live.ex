defmodule FranklinWeb.Admin.Articles.EditorLive do
  @moduledoc """
  Presents a form allowing an admin to create or edit an `Article` entity.
  """

  use FranklinWeb, :admin_live_view

  require Logger

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Franklin.Articles.Slugs
  alias FranklinWeb.Admin.Articles.ArticleForm
  alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView.Socket

  def render(assigns) do
    ~H"""
    <h2 class="text-xl font-bold my-4">Article Editor</h2>

    <.form
      :let={f}
      for={@form_changeset}
      id="new_article"
      autocomplete="off"
      phx-submit="save_form"
      phx-change="form_changed"
    >
      <!-- Title -->
      <.text_input form={f} field={:title} is_form_group is_full_width />
      <!-- Slug -->
      <.form_group field="slug">
        <fieldset disabled={Phoenix.HTML.Form.input_value(f, :slug_autogenerate)}>
          <.text_input form={f} field={:slug} is_full_width />
        </fieldset>

        <.form_group field="slug_autogenerate" is_hide_label class="mt-1">
          <.checkbox form={f} field={:slug_autogenerate}>
            <:label>Autogenerate slug from title.</:label>
          </.checkbox>
        </.form_group>
      </.form_group>
      <!-- Published at -->
      <.text_input form={f} field={:published_at} is_form_group is_full_width />
      <!-- Body -->
      <.form_group field="body">
        <section phx-drop-target={@uploads.attachment.ref}>
          <.textarea
            form={f}
            field={:body}
            rows="10"
            is_large
            is_full_width
            phx-hook="TextareaMutation"
          />
          <.admin_file_input_group upload={@uploads.attachment} upload_progress={@upload_progress} />
        </section>
      </.form_group>
      <.button is_submit is_primary>Save Article</.button>
    </.form>
    """
  end

  def mount(params, _session, socket) do
    socket
    |> assign_article(params)
    |> assign_form()
    |> assign_form_changeset(%{})
    |> assign_uploaded_files()
    |> assign_upload_progress()
    |> setup_subscription(params)
    |> ok()
  end

  @spec assign_article(Socket.t(), map()) :: Socket.t()
  defp assign_article(socket, %{"id" => id}) do
    case Articles.fetch_article(id) do
      {:ok, article} ->
        assign(socket, article: article)

      {:error, :article_not_found} ->
        raise FranklinWeb.NotFoundError
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

  defp assign_uploaded_files(socket) do
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:attachment,
      accept: ~w(.jpg .jpeg .png .gif .mp4),
      max_entries: 10,
      external: &presign_upload/2,
      progress: &handle_progress/3,
      auto_upload: true
    )
  end

  defp assign_upload_progress(socket) do
    # A simple map where the keys are the `entity_uuid` and the values are the
    # upload progress percentage as an integer.
    assign(socket, :upload_progress, %{})
  end

  defp assign_upload_progress(socket, entity_uuid, percent) when is_integer(percent) do
    %{assigns: %{upload_progress: upload_progress}} = socket

    upload_progress =
      upload_progress
      |> Map.put(entity_uuid, percent)
      |> clear_upload_progress_when_all_progress_is_100_percent()

    assign(socket, upload_progress: upload_progress)
  end

  defp clear_upload_progress_when_all_progress_is_100_percent(upload_progress) do
    # Because a user might upload multiple groups of files in different batches
    # and we need a way to present overall upload progress of a single batch, we
    # need to clear out our progress tracking map when all the progress is 100%.
    if Enum.all?(upload_progress, fn {_key, value} -> value == 100 end) do
      %{}
    else
      upload_progress
    end
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

  def handle_event("update_body", %{"body" => body}, socket) do
    # Via this somewhat hack of an event the frontend Javascript hooks can tell
    # the LiveView to update the body value explicitly. This is needed to
    # accomplish some specific editor features around presenting an in-progress
    # upload comment and then later updating it with the final URL.
    new_changeset = Ecto.Changeset.put_change(socket.assigns.form_changeset, :body, body)

    socket
    |> assign(form_changeset: new_changeset)
    |> noreply()
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

  defp maybe_assign_autogenerated_slug(
         %{
           "title" => title,
           "published_at" => published_at,
           "slug_autogenerate" => "false"
         } = form_params
       ) do
    with false <- Map.has_key?(form_params, "slug"),
         {:ok, datetime, _} <- DateTime.from_iso8601(published_at),
         {:ok, slug} <- Slugs.generate_slug_for_title(title, datetime) do
      Map.put(form_params, "slug", slug)
    else
      _ -> form_params
    end
  end

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
    |> redirect(to: path(socket, FranklinWeb.Router, ~p"/admin/articles/#{id}"))
    |> noreply()
  end

  defp handle_progress(:attachment, %Phoenix.LiveView.UploadEntry{done?: done?} = entry, socket)
       when done? do
    attachment_url =
      consume_uploaded_entry(socket, entry, fn %{url: url} ->
        url =
          url
          |> remove_presign_url_parameters()
          |> maybe_add_markdown_image_syntax()

        {:ok, url}
      end)

    socket
    |> assign_upload_progress(entry.uuid, 100)
    |> replace_upload_progress_description_in_body(entry.client_name, attachment_url)
    |> noreply()
  end

  defp handle_progress(
         :attachment,
         %Phoenix.LiveView.UploadEntry{progress: progress} = entry,
         socket
       ) do
    socket
    |> assign_upload_progress(entry.uuid, progress)
    |> noreply()
  end

  defp maybe_add_markdown_image_syntax(url) do
    if String.ends_with?(url, [".jpg", ".jpeg", ".gif", ".png"]) do
      "![](#{url})"
    else
      url
    end
  end

  defp presign_upload(entry, socket) do
    unique_filename = "#{entry.uuid}/#{entry.client_name}"

    case Franklin.S3Storage.generate_presigned_url(unique_filename) do
      {:ok, presigned_url} ->
        socket =
          socket
          |> assign_upload_progress(entry.uuid, 0)
          |> push_event("textarea_inject_request", %{
            content: upload_progress_description(entry.client_name)
          })

        {:ok, %{uploader: "S3", url: presigned_url}, socket}

      {:error, reason} ->
        # Even though we could not generate a presigned URL, we still need to
        # return an `{:ok, metadata, socket}` shaped value, else LiveView enters
        # a never ending crash/reload/crash loop. We will log the error for
        # observation.

        Logger.error(
          message: "Failed to generate presigned URL for entry",
          entry: entry,
          reason: reason
        )

        {:ok, %{uploader: "S3", error: reason}, socket}
    end
  end

  defp replace_upload_progress_description_in_body(socket, filename, new_content) do
    # This function will update the LiveView body assign as well as push an
    # event to the frontend JavaScript to do the same. We are doing it in two
    # places because the upload feature needs to work when the body textarea is
    # in focus and when it is not. This is not ideal, and a is a hacky way
    # around the LiveView focus lock.
    current_body = Ecto.Changeset.fetch_field!(socket.assigns.form_changeset, :body) || ""
    upload_description = upload_progress_description(filename)
    new_body = String.replace(current_body, upload_description, new_content)
    new_changeset = Ecto.Changeset.put_change(socket.assigns.form_changeset, :body, new_body)

    socket
    |> assign(:form_changeset, new_changeset)
    |> push_event("textarea_replace_request", %{
      target: upload_description,
      replacement: new_content
    })
  end

  defp upload_progress_description(filename) do
    "<!-- Uploading #{filename}... -->"
  end

  defp remove_presign_url_parameters(url) do
    if String.contains?(url, "?") do
      url |> String.split("?") |> hd()
    else
      url
    end
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}

  @spec noreply(Socket.t()) :: {:noreply, Socket.t()}
  defp noreply(socket), do: {:noreply, socket}
end
