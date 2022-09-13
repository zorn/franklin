defmodule Franklin.Posts.Commands.UpdatePost do
  @moduledoc """
  A command to represent the user-semantic intent of
  updating an existing `Post` entity.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Franklin.Posts.Validations

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          title: String.t()
        }

  @type command_attrs :: %{
          required(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @typedoc """
  A map containing attribute specific validation error strings.

  ## Example:

  > %{
  >   id: ["is invalid"],
  >   published_at: ["can't be blank"],
  >   title: ["should be at least 3 character(s)"]
  > }
  """
  @type errors :: %{atom() => list(String.t())}

  @primary_key {:id, Ecto.UUID, autogenerate: false}

  embedded_schema do
    field :published_at, :utc_datetime
    field :title, :string
  end

  @doc """
  Attempts to create a new `UpdatePost` command using the given attributes.

  If a valid command can be created `{:ok, command}` is returned.

  If a valid command can not be created `{:error, errors}` is returned. See the
  `errors()` typedoc for details.
  """
  @spec new(command_attrs()) :: {:ok, __MODULE__.t()} | {:error, errors()}
  def new(command_attrs) do
    case apply_action(changeset(%__MODULE__{}, command_attrs), :validate) do
      {:ok, command} -> {:ok, command}
      {:error, changeset} -> {:error, format_errors(changeset)}
    end
  end

  defp changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :published_at, :title])
    |> validate_id()
    |> validate_published_at()
    |> validate_title()
  end

  @spec format_errors(Ecto.Changeset.t()) :: errors()
  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
