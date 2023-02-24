defmodule Franklin.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string, null: false
      add :slug, :string, null: false
      add :body, :text, null: false
      add :published_at, :utc_datetime, null: true
      timestamps()
    end

    create unique_index(:articles, [:slug])
    create index(:articles, [:published_at])
  end
end
