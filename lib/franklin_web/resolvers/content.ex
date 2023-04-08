defmodule FranklinWeb.Resolvers.Content do
  alias Franklin.Articles

  def list_articles(_parent, _args, _resolution) do
    {:ok, Articles.list_articles(%{published_only: true})}
  end

  def find_article(_parent, %{id: id}, _resolution) do
    Articles.fetch_article(id)
  end
end
