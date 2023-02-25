defmodule FranklinWeb.PublicUserStories.CanDownloadRssFeedTest do
  @moduledoc """
  Asserts the business rule that a website visitor can download an RSS feed of the site's articles.
  """

  use FranklinWeb.ConnCase

  setup %{conn: conn} do
    articles =
      -1..-5
      |> Enum.map(fn n ->
        published_at = DateTime.add(DateTime.utc_now(), n, :day) |> DateTime.truncate(:second)
        create_article!(~M{published_at})
      end)

    ~M{conn, articles}
  end

  test "can download RSS file", ~M{conn, articles} do
    expected_response =
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Mike Zornek</title>
          <link>http://mikezornek.com/</link>
          <description>Programming, Elixir, tech, video games and personal journals.</description>
          <language>en-us</language>
          <copyright>Mike Zornek</copyright>
          <generator>Franklin - https://github.com/zorn/franklin/</generator>
          <lastBuildDate>#{DateTime.utc_now() |> DateTime.to_iso8601()}</lastBuildDate>
        </channel>
      </rss>
      """
      |> String.trim()

    # FIXME: That lastBuildDate is not correct. It needs to be RFC 2822.
    # lastBuildDate: should be based on the most recent article in the feed
    conn = get(conn, "/index.xml")
    IO.inspect(conn.resp_body)
    assert conn.resp_body == expected_response
  end
end
