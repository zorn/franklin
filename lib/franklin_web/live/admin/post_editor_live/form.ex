defmodule FranklinWeb.Admin.PostEditorLive.Form do
  @moduledoc """
  Defines the structure of the post editor form submission.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          title: String.t()
        }

  embedded_schema do
    field :title, :string
    field :published_at, :utc_datetime_usec
  end

  @spec changeset(%__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(form, params) do
    form
    |> cast(params, [:title, :published_at])
    |> validate_required([:title, :published_at])
    # FIXME: Using smaller length range for testing for now.
    |> validate_length(:title, min: 3, max: 50)
  end
end
