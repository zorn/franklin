defmodule FranklinWeb.SyndicationController do
  use FranklinWeb, :controller

  alias Franklin.RssFeed

  def rss(conn, _params) do
    conn
    |> put_resp_content_type("application/rss+xml")
    |> text(RssFeed.new([]))
  end
end
