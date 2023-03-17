defmodule FranklinWeb.Admin.UploadDemoLive do
  use FranklinWeb, :live_view

  require Logger

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1>Upload Demo</h1>

    <form id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.avatar} />
      <button type="submit">Upload</button>
    </form>

    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
    <section phx-drop-target={@uploads.avatar.ref}>
      <%!-- render each avatar entry --%>
      <%= for entry <- @uploads.avatar.entries do %>
        <article class="upload-entry">
          <figure>
            <.live_img_preview entry={entry} />
            <figcaption><%= entry.client_name %></figcaption>
          </figure>

          <%!-- entry.progress will update automatically for in-flight entries --%>
          <progress value={entry.progress} max="100"><%= entry.progress %>%</progress>

          <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
          <button
            type="button"
            phx-click="cancel-upload"
            phx-value-ref={entry.ref}
            aria-label="cancel"
          >
            &times;
          </button>

          <%!-- Phoenix.Component.upload_errors/2 returns a list of error atoms --%>
          <%= for err <- upload_errors(@uploads.avatar, entry) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
        </article>
      <% end %>

      <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
      <%= for err <- upload_errors(@uploads.avatar) do %>
        <p class="alert alert-danger"><%= error_to_string(err) %></p>
      <% end %>
    </section>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg),
       max_entries: 3,
       external: &presign_upload/2,
       progress: &handle_progress/3,
       auto_upload: true
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", _params, socket) do
    # dbg(socket.assigns.uploaded_files)

    # uploaded_files =
    #   consume_uploaded_entries(socket, entry, fn %{url: url}, _entry ->
    #     {:ok, remove_presign_url_parameters(url)}
    #   end)

    {:noreply, socket}
  end

  defp handle_progress(:avatar, %Phoenix.LiveView.UploadEntry{done?: done?} = entry, socket)
       when done? do
    avatar_url =
      consume_uploaded_entry(socket, entry, fn %{url: url} ->
        {:ok, remove_presign_url_parameters(url)}
      end)

    dbg(avatar_url)

    {:noreply, socket}
  end

  defp handle_progress(:avatar, _entry, socket) do
    # Catch all for when progress is not done.
    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  defp error_to_string(:external_client_failure),
    do: "The external client failed to upload the file"

  defp presign_upload(entry, socket) do
    case Franklin.S3Storage.generate_presigned_url(entry.client_name) do
      {:ok, presigned_url} ->
        {:ok, %{uploader: "S3", url: presigned_url}, socket}

      {:error, reason} ->
        # Even though we could not generate a presigned URL, we still need to
        # return an `{:ok, metadata, socket}` shaped value, else LiveView enters a never ending crash/reload/crash loop. We will log the error for observation.

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
end
