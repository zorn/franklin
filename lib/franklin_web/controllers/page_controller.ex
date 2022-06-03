defmodule FranklinWeb.PageController do
  use FranklinWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
