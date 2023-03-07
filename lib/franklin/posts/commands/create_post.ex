defmodule Franklin.Posts.Commands.CreatePost do
  use Ecto.Schema

  import Ecto.Changeset
  import Franklin.Posts.Validations

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          title: String.t()
        }

  # TODO: Add typedoc.

  @type new_attrs :: %{
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @type error_list :: %{atom() => list(String.t())}

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  embedded_schema do
    field :published_at, :utc_datetime_usec
    field :title, :string
  end

  @doc """
  Given a map of potential values attempts to return a valid `CreatePost` command.

  If the values are valid, returns: `{:ok, command}`.

  If the values are invalid, returns: `{:error, list}` where `list` is a keyword
  list breakdown of the invalid reasons.

  ## Expected Keys:

    * `title` - A string value between 3 and 100 characters in length.
    * `published_at` - A `DateTime` value.
    * `id` - (optional) An `Ecto.UUID` value that will be used as the identity
      of this post. Will be generated if not provided.

  ## Examples:

     > iex> CreatePost.new(123, nil, nil)
     > %{
     >   id: ["is invalid"],
     >   published_at: ["can't be blank"],
     >   title: ["can't be blank"]
     > }

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
