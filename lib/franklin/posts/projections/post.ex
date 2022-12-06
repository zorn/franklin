defmodule Franklin.Posts.Projections.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          published_at: DateTime.t(),
          title: String.t()
        }

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "posts" do
    field :title, :string
    field :published_at, :utc_datetime

    timestamps()
  end

  def update_changeset(post, attrs \\ %{}) do
    cast(post, attrs, [:title, :published_at])
  end
end
