defmodule FranklinWeb.Resolvers.Content do
  alias Franklin.Articles

  def list_articles(_parent, _args, _resolution) do
    {:ok, Articles.list_articles()}
  end

  def find_article(_parent, %{id: id}, _resolution) do
    Articles.fetch_article(id)
  end

  def generate_upload_url(_parent, %{filename: filename}, _resolution) do
    case Franklin.S3Storage.generate_presigned_url(filename) do
      {:ok, url} -> {:ok, %{url: url}}
      {:error, _} -> {:error, "Could not generate presigned url."}
    end
  end
end
