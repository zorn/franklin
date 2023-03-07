defmodule FranklinWeb.PublicUserStories.CanDownloadRssFeedTest do
  @moduledoc """
  Asserts the business rule that a website visitor can download an RSS feed of
  the site's recently updated articles.
  """

  use FranklinWeb.ConnCase

  alias Franklin.Articles.Article
  alias Franklin.DateTimeFormatter

  setup %{conn: conn} do
    article1 =
      create_article!(%{
        published_at: DateTime.add(DateTime.utc_now(), -1, :day)
      })

    article2 =
      create_article!(%{
        published_at: DateTime.add(DateTime.utc_now(), -2, :day)
      })

    article3 =
      create_article!(%{
        published_at: DateTime.add(DateTime.utc_now(), -3, :day)
      })

    ~M{conn, article1, article2, article3}
  end

  test "can download RSS file", ~M{conn, article1, article2, article3} do
    expected_response =
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <atom:link href="https://test.mikezornek.com/index.xml" rel="self" type="application/rss+xml"/>
          <title>Mike Zornek</title>
          <link>https://test.mikezornek.com</link>
          <description>Programming, Elixir, tech, video games and personal journals.</description>
          <language>en-us</language>
          <copyright>Mike Zornek</copyright>
          <generator>Franklin - https://github.com/zorn/franklin/</generator>
          <lastBuildDate>#{DateTimeFormatter.to_rfc_2822(article1.published_at)}</lastBuildDate>
          <item>
            <guid>https://test.mikezornek.com/articles/#{article1.slug}</guid>
            <title>#{article1.title}</title>
            <link>https://test.mikezornek.com/articles/#{article1.slug}</link>
            <author>mike@mikezornek.com (Mike Zornek)</author>
            <description><![CDATA[#{rendered_body(article1)}]]></description>
            <pubDate>#{DateTimeFormatter.to_rfc_2822(article1.published_at)}</pubDate>
          </item>
          <item>
            <guid>https://test.mikezornek.com/articles/#{article2.slug}</guid>
            <title>#{article2.title}</title>
            <link>https://test.mikezornek.com/articles/#{article2.slug}</link>
            <author>mike@mikezornek.com (Mike Zornek)</author>
            <description><![CDATA[#{rendered_body(article2)}]]></description>
            <pubDate>#{DateTimeFormatter.to_rfc_2822(article2.published_at)}</pubDate>
          </item>
          <item>
            <guid>https://test.mikezornek.com/articles/#{article3.slug}</guid>
            <title>#{article3.title}</title>
            <link>https://test.mikezornek.com/articles/#{article3.slug}</link>
            <author>mike@mikezornek.com (Mike Zornek)</author>
            <description><![CDATA[#{rendered_body(article3)}]]></description>
            <pubDate>#{DateTimeFormatter.to_rfc_2822(article3.published_at)}</pubDate>
          </item>
        </channel>
      </rss>
      """
      |> String.trim()

    conn = get(conn, "/index.xml")
    assert conn.resp_body == expected_response
  end

  defp rendered_body(%Article{body: body}) do
    {:ok, html_doc, _deprecation_messages} = Earmark.as_html(body)
    html_doc
  end
end
