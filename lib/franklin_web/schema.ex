defmodule FranklinWeb.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(FranklinWeb.Schema.ContentTypes)

  alias FranklinWeb.Resolvers

  query do
    @desc "Get a list of the articles."
    field :articles, list_of(:article) do
      resolve(&Resolvers.Content.list_articles/3)
    end

    @desc "Get an article by its id value."
    field :article, :article do
      arg(:id, :id)
      resolve(&Resolvers.Content.find_article/3)
    end
  end
end
