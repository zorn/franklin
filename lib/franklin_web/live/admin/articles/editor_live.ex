defmodule FranklinWeb.Admin.Articles.EditorLive do
  @moduledoc """
  Presents a form allowing an admin to create or edit a `Article` entity.
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
      phx-hook="AttachmentUrlInserter"
    >
      <!-- Title -->
      <.form_group field="title">
        <.text_input form={f} field={:title} is_full_width />
      </.form_group>
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
      <!-- Published At -->
      <.form_group field="published_at">
        <.text_input form={f} field={:published_at} is_full_width />
      </.form_group>
      <!-- Body -->
      <.form_group field="body">
        <%!-- I feel like I'm going to have to drop the Primer `textarea` and do my own because I'm going to want to wrap the error ring around the textarea and the footer part. In time I might be able to come back and make this a legit `MarkdownEditor` -- though I'm folling the issue markdown editor style while the other components seem to be using the newer Project style MarkdownEditor. --%>
        <%!-- It's probably important to work on a short term design here, to get uploads wokring in a reasonabe way and make new issue to come back and make the component design better. --%>
        <section phx-drop-target={@uploads.attachment.ref}>
          <.textarea form={f} field={:body} rows="10" is_large is_full_width />
        </section>
        <%!-- TODO: Should a user be able to start a new upload while one is already in progress? --%>
        <div class="mt-1 py-1 flex items-center justify-between bg-gray-100 border border-gray-400 border-solid rounded">
          <div class="ml-2 text-gray-600">
            <label class="font-normal">
              <%= if show_upload_progress?(@upload_progress) do %>
                <%!-- todo: for those files in progress figure out overall progress --%>
                <%!-- <svg class="animate-spin h-5 w-5 mr-3 ..." viewBox="0 0 24 24">
                  <!-- ... -->
                </svg> --%>
                <%!-- TODO: Break this out into it's own component. --%>
                <div class="flex items-center">
                  <svg
                    class="animate-spin mr-1 h-4 w-4"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    >
                    </circle>
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    >
                    </path>
                  </svg>
                  Files uploading... (<%= overall_upload_progress(@upload_progress) %>%)
                </div>
              <% else %>
                Attach files by dragging & dropping, <span class="underline">selecting</span>
                or pasting them.
              <% end %>

              <.live_file_input class="hidden" upload={@uploads.attachment} />
            </label>
          </div>
          <.octicon name="markdown-16" class="mr-2" />
        </div>
      </.form_group>
      <.button is_submit is_primary>Save Article</.button>
    </.form>
    """
  end

  defp show_upload_progress?(upload_progress) do
    upload_progress
    |> Map.values()
    |> Enum.any?(fn progress -> progress < 100 end)
  end

  defp overall_upload_progress(upload_progress) when map_size(upload_progress) == 0, do: 0

  defp overall_upload_progress(upload_progress) do
    number_of_entries = Enum.count(upload_progress)
    all_values = Map.values(upload_progress)
    dbg(all_values)
    (Enum.sum(all_values) / number_of_entries) |> floor()
  end

  def mount(params, _session, socket) do
    socket
    |> assign_article(params)
    |> assign_form()
    |> assign_form_changeset(%{})
    |> assign_uploaded_files()
    # TODO: `upload_progress` is a poor name.
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
    # We'll use this map to track the progress of each upload.
    # Q: When should we clear this map?
    assign(socket, :upload_progress, %{})
  end

  defp assign_upload_progress(
         %{assigns: %{upload_progress: upload_progress}} = socket,
         entity_uuid,
         percent
       )
       when is_integer(percent) do
    upload_progress = Map.put(upload_progress, entity_uuid, percent)
    dbg(upload_progress)

    # TODO: make this a named function.
    upload_progress =
      if Enum.all?(upload_progress, fn {_key, value} -> value == 100 end) do
        %{}
      else
        upload_progress
      end

    assign(socket, upload_progress: upload_progress)
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
        {:ok, remove_presign_url_parameters(url)}
      end)

    dbg(attachment_url)
    # Add the url to the body of the article.
    current_body = Ecto.Changeset.fetch_field!(socket.assigns.form_changeset, :body) || ""
    dbg(current_body)
    # TODO: It would be better if this did not add a new line if the body was previously empty.
    # TODO: When the attachment is an image we should add some markdown image syntax.
    # TODO: Maybe we should push this as event to the JS client so it can insert
    # at the cursor location and is not effected by the LiveView focus lock?
    new_body = current_body <> "\n#{attachment_url}"
    new_changeset = Ecto.Changeset.put_change(socket.assigns.form_changeset, :body, new_body)

    socket
    |> assign_upload_progress(entry.uuid, 100)
    |> assign(form_changeset: new_changeset)
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

  defp presign_upload(entry, socket) do
    unique_filename = "#{entry.uuid}/#{entry.client_name}"

    case Franklin.S3Storage.generate_presigned_url(unique_filename) do
      {:ok, presigned_url} ->
        # For each presigned_url we generate, let's keep track of the upload_progress starting at 0.
        socket = assign_upload_progress(socket, entry.uuid, 0)

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
