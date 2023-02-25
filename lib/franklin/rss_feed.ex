defmodule Franklin.RssFeed do
  import XmlBuilder

  alias Franklin.Articles.Article
  alias Franklin.DateTimeFormatter

  @spec new([Article.t()]) :: String.t()
  def new(articles) when is_list(articles) do
    document([
      element(
        :rss,
        %{version: "2.0"},
        [
          element(:channel, [
            element(:title, "Mike Zornek"),
            element(:link, "http://mikezornek.com/"),
            element(
              :description,
              "Programming, Elixir, tech, video games and personal journals."
            ),
            element(:language, "en-us"),
            element(:copyright, "Mike Zornek"),
            element(:generator, "Franklin - https://github.com/zorn/franklin/"),
            element(:lastBuildDate, last_build_date(articles) |> DateTimeFormatter.to_rfc_2822())
          ])
        ]
      )
    ])
    |> generate

    # items = MyApp.Article
    #         |> MyApp.Repo.all()
    #         |> Enum.map(&article_to_rss_item/1)

    # xml_feed do
    #   rss version: "2.0" do
    #     channel do
    #       title "My App Articles"
    #       link "https://example.com/feed"
    #       description "Latest articles from My App"
    #       language "en-us"
    #       pubDate DateTime.utc_now() |> DateTime.to_rfc2822()

    #       items |> Enum.each(&insert_element/1)
    #     end
    #   end
    # end
  end

  defp last_build_date(articles) when is_list(articles) and length(articles) > 0 do
    sorted_articles_newest_first =
      Enum.sort_by(articles, & &1.published_at, {:desc, NaiveDateTime})

    %Article{published_at: last_build_date} = List.first(sorted_articles_newest_first)
    dbg(last_build_date)
  end

  defp last_build_date(_articles), do: DateTime.utc_now()
end

# <?xml version="1.0" encoding="utf-8" standalone="yes"?>
# <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
#   <channel>
#     <title>Mike Zornek</title>
#     <link>http://mikezornek.com/</link>
#     <description>Recent content in Home on Mike Zornek</description>
#     <generator>Hugo -- gohugo.io</generator>
#     <language>en-us</language>
#     <lastBuildDate>Mon, 20 Feb 2023 11:17:10 -0500</lastBuildDate>

#     <atom:link href="http://mikezornek.com/index.xml" rel="self" type="application/rss+xml" />

# <item>
# <title>Spring 2023 Elixir Consulting Availability</title>
# <link>http://mikezornek.com/posts/2023/2/elixir-consulting-availability/</link>
# <pubDate>Mon, 20 Feb 2023 11:17:10 -0500</pubDate>

# <guid>http://mikezornek.com/posts/2023/2/elixir-consulting-availability/</guid>
# <description>

#   &lt;p&gt;I am looking for my next consulting gig.&lt;/p&gt;

#   &lt;p&gt;I want to contribute to an &lt;strong&gt;Elixir&lt;/strong&gt;,
#   &lt;strong&gt;Phoenix&lt;/strong&gt;, and/or &lt;strong&gt;LiveView&lt;/strong&gt; project.
#   An ideal engagement is around &lt;strong&gt;20-32 hours per week&lt;/strong&gt;; leaving
#   time to maintain other active projects. Larger commitments will be considered for the right
#   project fit.&lt;/p&gt;

# </description>
# </item>
