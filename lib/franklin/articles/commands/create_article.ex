defmodule Franklin.Articles.Commands.CreateArticle do
  use Ecto.Schema

  import Ecto.Changeset
  import Franklin.Articles.Validations

  @type t :: %__MODULE__{
          body: String.t(),
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          title: String.t()
        }

  # TODO: Add typedoc.

  @type new_attrs :: %{
          required(:body) => String.t(),
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @type error_list :: %{atom() => list(String.t())}

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  embedded_schema do
    field :published_at, :utc_datetime
    field :body, :string
    field :title, :string
  end

  @doc """
  Attempts to return a valid `CreatePost` command using the passes in attribute map.

  If the attributes are valid, returns: `{:ok, command}`.

  If the attributes are invalid, returns: `{:error, list}` where `list` is a keyword
  list breakdown of the invalid reasons.
  """
  @spec new(map()) :: {:ok, __MODULE__.t()} | {:error, error_list()}
  def new(attrs) do
    attrs = Map.put_new(attrs, :id, Ecto.UUID.generate())

    case apply_action(changeset(%__MODULE__{}, attrs), :validate) do
      {:ok, command} ->
        {:ok, command}

      {:error, changeset} ->
        {:error, format_errors(changeset)}
    end
  end

  defp changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :published_at, :title])
    |> validate_id()
    |> validate_published_at()
    |> validate_title()
    |> validate_body()
  end

  @spec format_errors(Ecto.Changeset.t()) :: error_list()
  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
