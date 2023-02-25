defmodule FranklinWeb.SyndicationController do
  use FranklinWeb, :controller

  alias Franklin.RssFeed
  alias Franklin.Articles

  def rss(conn, _params) do
    recent_articles =
      Articles.list_articles(%{
        limit: 10,
        published_only: true
      })

    conn
    |> put_resp_content_type("application/rss+xml")
    |> text(RssFeed.new(recent_articles))
  end
end
