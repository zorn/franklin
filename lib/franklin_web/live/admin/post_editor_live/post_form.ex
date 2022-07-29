defmodule FranklinWeb.Admin.PostEditorLive.PostForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :title
    field :published_at
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
