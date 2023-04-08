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

  def create_article(_parent, %{input: input}, _resolution) do
    input
    |> Articles.create_article()
    |> format_payload()
  end

  defp format_payload({:ok, article_id}) do
    {:ok, %{article_id: article_id}}
  end

  defp format_payload({:error, validation_error_map}) do
    validation_error_map = stringify_keys(validation_error_map)
    {:error, message: "A database error occurred", details: validation_error_map}
  end

  defp stringify_keys(map) do
    Enum.reduce(map, %{}, fn {key, value}, acc ->
      Map.put(acc, to_string(key), value)
    end)
  end
end
