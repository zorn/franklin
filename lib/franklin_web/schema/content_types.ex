defmodule FranklinWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  object :article do
    field :id, :id
    field :title, :string
    field :body, :string
  end
end
