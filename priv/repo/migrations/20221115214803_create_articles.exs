defmodule Franklin.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :body, :text
      add :published_at, :utc_datetime
      timestamps()
    end
  end
end
