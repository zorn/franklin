defmodule FranklinWeb.Resolvers.Content do
  def list_articles(_parent, _args, _resolution) do
    {:ok, Franklin.Articles.list_articles(%{published_only: true})}
  end
end
