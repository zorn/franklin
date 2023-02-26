defmodule FranklinWeb.RssFeed do
  @moduledoc """
  Provides functions in support of the generation of an RSS feed helping people
  keep up to date with the latest articles.
  """

  import XmlBuilder

  alias Franklin.Articles.Article
  alias Franklin.DateTimeFormatter
  alias FranklinWeb.Router.Helpers, as: Routes

  @config Application.compile_env(:franklin, __MODULE__)
  @url Keyword.fetch!(@config, :url)

  @doc """
  Returns a string value containing an RSS feed for the given collection of articles.
  """
  @spec new([Article.t()]) :: String.t()
  def new(articles) when is_list(articles) do
    document([
      element(
        :rss,
        %{version: "2.0"},
        [
          element(
            :channel,
            [
              element(
                "atom:link",
                %{
                  href: "#{@url}/index.xml",
                  rel: "self",
                  type: "application/rss+xml"
                }
              ),
              element(:title, "Mike Zornek"),
              element(:link, @url),
              element(
                :description,
                "Programming, Elixir, tech, video games and personal journals."
              ),
              element(:language, "en-us"),
              element(:copyright, "Mike Zornek"),
              element(:generator, "Franklin - https://github.com/zorn/franklin/"),
              element(
                :lastBuildDate,
                last_build_date(articles) |> DateTimeFormatter.to_rfc_2822()
              )
            ] ++ Enum.map(articles, &article_to_rss_item/1)
          )
        ]
      )
    ])
    |> generate
  end

  defp article_to_rss_item(article) do
    # FIXME: We should process this during the projection process.
    # https://github.com/zorn/franklin/issues/96
    {:ok, html_doc, _deprecation_messages} = Earmark.as_html(article.body)

    element(:item, [
      element(:guid, article_link(article)),
      element(:title, article.title),
      element(:link, article_link(article)),
      element(:author, "mike@mikezornek.com (Mike Zornek)"),
      element(:description, {:cdata, html_doc}),
      element(:pubDate, DateTimeFormatter.to_rfc_2822(article.published_at))
    ])
  end

  defp article_link(%Article{slug: slug}) do
    path =
      Routes.article_viewer_path(
        FranklinWeb.Endpoint,
        :show,
        String.split(slug, "/")
      )

    "#{@url}#{path}"
  end

  defp last_build_date(articles) when is_list(articles) and length(articles) > 0 do
    sorted_articles_newest_first =
      Enum.sort_by(articles, & &1.published_at, {:desc, NaiveDateTime})

    %Article{published_at: last_build_date} = List.first(sorted_articles_newest_first)

    last_build_date
  end

  defp last_build_date(_articles), do: DateTime.utc_now()
end
