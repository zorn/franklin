defmodule FranklinWeb.Components.Admin.FileInputGroup do
  @moduledoc """
  This component is used to render the LiveView file input experience as seen on
  the admin article editor.
  """

  use Phoenix.Component
  use PrimerLive

  import FranklinWeb.Components.Admin.AnimatedSpinner

  # FIXME: These attribute types are currently very coupled with the specific
  # module `FranklinWeb.Admin.Articles.EditorLive`. We should consider
  # refactoring them to be more general in the future.
  # https://github.com/zorn/franklin/issues/227
  attr :upload, :map, required: true
  attr :upload_progress, :map, required: true

  def admin_file_input_group(assigns) do
    ~H"""
    <div class="mt-1 py-1 flex items-center justify-between bg-gray-100 border border-gray-400 border-solid rounded">
      <div class="ml-2 text-gray-600">
        <label class="font-normal">
          <%= if show_upload_progress?(@upload_progress) do %>
            <div class="flex items-center">
              <.admin_animated_spinner />
              Files uploading... (<%= overall_upload_progress(@upload_progress) %>%)
            </div>
          <% else %>
            Attach files by dragging & dropping or <span class="underline">selecting</span> them.
          <% end %>
          <.live_file_input class="hidden" upload={@upload} />
        </label>
      </div>
      <.octicon name="markdown-16" class="mr-2" />
    </div>
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
end
