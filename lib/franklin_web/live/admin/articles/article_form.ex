defmodule FranklinWeb.Admin.Articles.ArticleForm do
  @moduledoc """
  Defines the structure of the article editor form.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Franklin.Articles.Validations

  alias Franklin.Articles.Article

  embedded_schema do
    field :body, :string
    field :published_at, :utc_datetime
    field :title, :string
  end

  @castable_attribute_fields [
    :body,
    :published_at,
    :title
  ]

  @spec new(Article.t()) :: %__MODULE__{}
  def new(article) do
    %__MODULE__{
      title: article.title,
      body: article.body,
      published_at: article.published_at
    }
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(form, params) do
    form
    |> cast(params, @castable_attribute_fields)
    |> validate_body()
    |> validate_published_at()
    |> validate_title()
  end
end
