defmodule Franklin.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :published_at, :utc_datetime
      timestamps(type: :utc_datetime)
    end
  end
end
