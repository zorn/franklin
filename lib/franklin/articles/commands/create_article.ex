defmodule Franklin.Articles.Commands.CreateArticle do
  @moduledoc """
  A command to represent the user intent of creating a new `Article` entity.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Franklin.Articles.Validations

  alias Franklin.ValidationErrorMap

  @type t :: %__MODULE__{
          body: String.t(),
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          title: String.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  embedded_schema do
    field :body, :string
    field :published_at, :utc_datetime
    field :title, :string
  end

  @castable_attribute_fields [
    :body,
    :id,
    :published_at,
    :title
  ]

  @typedoc """
  Attribute map type relative to the `new/1` function.

  ## Attributes

    * `:body` - A Markdown-flavored string value no more that 100 MBs in length.
    * `:id` - (optional) An `Ecto.UUID` value that will be used as the
       identity of this article. Will be generated if not provided.
    * `:published_at` - A `DateTime` value representing the public-facing
       publication date of the article.
    * `:title` - A plain-text string value using 1 to 255 characters in length.
  """
  @type new_attrs :: %{
          required(:body) => String.t(),
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @doc """
  Attempts to return a `CreateArticle` command.

  If the attributes are valid, returns: `{:ok, command}`. If the attributes are
  invalid, returns: `{:error, validation_error_map}`.
  """
  @spec new(new_attrs()) :: {:ok, __MODULE__.t()} | {:error, ValidationErrorMap.t()}
  def new(new_attrs) do
    # `id` is optional, if not present, generate one.
    new_attrs = Map.put_new(new_attrs, :id, Ecto.UUID.generate())

    case apply_action(changeset(%__MODULE__{}, new_attrs), :validate) do
      {:ok, command} -> {:ok, command}
      {:error, changeset} -> {:error, ValidationErrorMap.new(changeset)}
    end
  end

  defp changeset(article, attrs) do
    article
    |> cast(attrs, @castable_attribute_fields)
    |> validate_body()
    |> validate_id()
    |> validate_published_at()
    |> validate_title()
  end
end
