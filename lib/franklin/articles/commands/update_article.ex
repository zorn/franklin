defmodule Franklin.Articles.Commands.UpdateArticle do
  @moduledoc """
  A command to represent the user-semantic intent of updating an existing `Article` entity.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Franklin.Articles.Validations

  alias Franklin.ValidationErrorMap

  @type t :: %__MODULE__{
          body: String.t(),
          id: Ecto.UUID.t(),
          published_at: DateTime.t() | nil,
          slug: String.t(),
          title: String.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  embedded_schema do
    field :body, :string
    field :published_at, :utc_datetime_usec
    field :slug, :string
    field :title, :string
  end

  @attribute_fields [
    :body,
    :id,
    :published_at,
    :slug,
    :title
  ]

  @type attrs :: %{
          required(:body) => String.t(),
          required(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:slug) => String.t(),
          required(:title) => String.t()
        }

  @doc """
  Attempts to return a `UpdateArticle` command using the passed in attributes.

  If the attributes are valid, returns: `{:ok, command}`. If the attributes are
  invalid, returns: `{:error, validation_error_map}`.
  """
  @spec new(attrs()) :: {:ok, __MODULE__.t()} | {:error, ValidationErrorMap.t()}
  def new(attrs) do
    case apply_action(changeset(%__MODULE__{}, attrs), :validate) do
      {:ok, command} -> {:ok, command}
      {:error, changeset} -> {:error, ValidationErrorMap.new(changeset)}
    end
  end

  defp changeset(user, attrs) do
    user
    |> cast(attrs, @attribute_fields)
    |> validate_body()
    |> validate_id()
    |> validate_published_at()
    |> validate_title()
    |> validate_slug(apply_unique_constraint: false)
  end
end
