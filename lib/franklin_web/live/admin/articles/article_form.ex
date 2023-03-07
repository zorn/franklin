defmodule FranklinWeb.Admin.Articles.ArticleForm do
  @moduledoc """
  Defines the structure of the article editor form.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Franklin.Articles.Validations

  alias Franklin.Articles.Article
  alias Franklin.Articles.Slugs

  @type t :: %__MODULE__{
          body: String.t(),
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          slug: String.t(),
          slug_autogenerate: boolean(),
          title: String.t()
        }

  embedded_schema do
    field :body, :string
    field :published_at, :utc_datetime_usec
    field :slug, :string
    field :slug_autogenerate, :boolean
    field :title, :string
  end

  @castable_attribute_fields [
    :body,
    :published_at,
    :slug,
    :slug_autogenerate,
    :title
  ]

  @spec new(Article.t()) :: %__MODULE__{}
  def new(article) do
    %__MODULE__{
      body: article.body,
      published_at: article.published_at,
      slug: article.slug,
      slug_autogenerate:
        article.title in [nil, ""] || current_slug_matches_generated_slug(article),
      title: article.title
    }
  end

  defp current_slug_matches_generated_slug(article) do
    case Slugs.generate_slug_for_title(article.title, article.published_at) do
      {:ok, slug} ->
        article.slug == slug

      {:error, _} ->
        false
    end
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(form, params) do
    form
    |> cast(params, @castable_attribute_fields)
    |> validate_body()
    |> validate_published_at()
    |> validate_title()
    |> validate_slug(apply_unique_constraint: false)
  end
end
