defmodule Franklin.RssFeed do
  import XmlBuilder

  alias Franklin.Repo

  def new(_articles) do
    document([
      element(
        :rss,
        %{version: "2.0"},
        [
          element(:channel, [
            element(:title, "Mike Zornek"),
            element(:link, "http://mikezornek.com/")
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
