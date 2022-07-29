defmodule Franklin.Posts do
  import Ecto.Query

  alias Franklin.Repo
  alias Franklin.Posts.Projections.Post

  def list_posts() do
    query = from p in Post, order_by: [desc: p.published_at]
    Repo.all(query)
  end
end
