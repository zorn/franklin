# FIXME: ContentPreview is a lame name
defmodule FranklinWeb.Components.ContentPreview do
  use Phoenix.Component

  attr :title, :string, required: true
  attr :summary, :string, required: true
  attr :url, :string, required: true
  attr :thumbnail_src, :string, required: true
  attr :thumbnail_alt_text, :string, required: true
  attr :published_at, :any, required: true

  @spec content_preview(map()) :: Phoenix.LiveView.Rendered.t()
  def content_preview(assigns) do
    ~H"""
    <div class="bg-gray-50 flex flex-row">
      <a href={@url}>
        <img alt={@thumbnail_alt_text} class="flex-none w-48" src={@thumbnail_src} />
      </a>

      <div class="flex-1 px-4">
        <a class="bold underline text-xl" href={@url}>
          <%= @title %>
        </a>

        <p>
          <%= @summary %>
        </p>

        <div class="text-right text-sm italic">
          Published on <%= inspect(@published_at) %>
        </div>
      </div>
    </div>
    """
  end
end
