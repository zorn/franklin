defmodule FranklinWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :article do
    field :id, :id
    field :title, :string
    field :body, :string
    field :slug, :string
    field :published_at, :datetime
  end
end
