defmodule FranklinWeb.Articles.ViewerLive do
  @moduledoc """
  A live view that presents articles for reading to public visitors.
  """
  use FranklinWeb, :live_view

  alias Franklin.Articles
  alias Franklin.Articles.Article
  alias Phoenix.LiveView.Socket

  @impl Phoenix.LiveView
  def mount(%{"slug" => slug}, _session, socket) do
    socket
    |> assign_article(slug)
    |> assign_rendered_body()
    |> ok()
  end

  @spec assign_article(Socket.t(), String.t()) :: Socket.t()
  defp assign_article(socket, slug) do
    slug = Enum.join(slug, "/") |> Kernel.<>("/")

    case Articles.fetch_article_by_slug(slug) do
      {:ok, article} ->
        if is_nil(article.published_at) do
          raise FranklinWeb.NotFoundError
          socket
        else
          assign(socket, article: article)
        end

      {:error, :article_not_found} ->
        raise FranklinWeb.NotFoundError
        socket
    end
  end

  @spec assign_rendered_body(Socket.t()) :: Socket.t()
  defp assign_rendered_body(%{assigns: %{article: %Article{body: nil}}} = socket) do
    assign(socket, rendered_body: nil)
  end

  defp assign_rendered_body(%{assigns: %{article: %Article{body: body}}} = socket) do
    {:ok, html_doc, _deprecation_messages} = Earmark.as_html(body)
    assign(socket, rendered_body: html_doc)
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="mb-8">
      <h1 id="article-headline" class="font-sans text-5xl font-bold mt-10 mb-1">
        <%= @article.title %>
      </h1>
      <div class="text-gray-400">Posted on Feb 28, 2023</div>
    </div>

    <div
      id="article-body"
      class={[
        "prose",
        with_large_text(),
        with_blockquote_styling_removed(),
        with_hover_link_style(),
        with_sans_headlines(),
        with_styled_hr()
      ]}
    >
      <%= raw(@rendered_body) %>
    </div>
    """
  end

  defp with_large_text() do
    # We prefer a slightly larger text for increased readability
    # because I am an old man and have bad eyes.
    "prose-lg"
  end

  def with_blockquote_styling_removed() do
    # The default Tailwind CSS Typography plugin adds quote marks to `blockquote` tags, but
    # we do not want them and have configured Tailwind with a `quoteless` prose
    # option. See `tailwind.config.js`.
    "prose-quoteless"
  end

  defp with_hover_link_style() do
    # Default Tailwind CSS Typography plugin does not underline links, but we
    # want them underlined and interactive on hover.
    "hover:prose-a:text-blue-600"
  end

  defp with_sans_headlines() do
    # Because our site defaults to a serif font we need to style each of the
    # numbered headlines to be serif.
    Enum.reduce(1..4, [], fn number, acc ->
      acc ++ [headline_text_size(number)]
    end)
    |> Enum.join(" ")
  end

  defp headline_text_size(1) do
    # While it might be tempting to do some string interpellation here, we can
    # not do so since the Tailwind build tools needs to see "h1" or "h2" in
    # the code to make sure it includes those styles in the final build
    # artifact.
    #
    # Also, while there are technically 6 headline levels, the Tailwind CSS
    # Typography plugin only does "prose" styling for the first four levels, so
    # we do not define anything for h5 of h6 here.
    "prose-h1:font-sans prose-h1:text-5xl prose-h1:mt-12 prose-h1:mb-4"
  end

  defp headline_text_size(2) do
    "prose-h2:font-sans prose-h2:text-4xl prose-h2:mt-12 prose-h2:mb-1"
  end

  defp headline_text_size(3) do
    "prose-h3:font-sans prose-h3:text-3xl prose-h3:mt-8 prose-h3:mb-1"
  end

  defp headline_text_size(4) do
    "prose-h4:font-sans prose-h4:text-2xl prose-h4:mt-4 prose-h4:mb-1"
  end

  defp with_styled_hr() do
    # We commonly use horizontal rules in the closing content of blog posts. The
    # default margins are large, so we'll condense them a bit.
    "prose-hr:my-6"
  end

  @spec ok(Socket.t()) :: {:ok, Socket.t()}
  defp ok(socket), do: {:ok, socket}
end
