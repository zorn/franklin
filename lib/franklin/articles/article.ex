defmodule Franklin.Articles.Article do
  @moduledoc """
  A long form of written content for the blog.

  This entity is a projection based on recorded events relative to a specific `Article`.
  """

  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "articles" do
    field :title, :string
    field :body, :string
    field :published_at, :utc_datetime

    timestamps()
  end
end
