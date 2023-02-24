defmodule Franklin.Articles.Events.ArticleCreated do
  @derive Jason.Encoder
  defstruct [
    :id,
    :title,
    :body,
    :slug,
    :published_at
  ]
end

defimpl Commanded.Serialization.JsonDecoder, for: Franklin.Articles.Events.ArticleCreated do
  @doc """
  Logic to convert string-based `published_at` JSON value into
  an Elixir DateTime value when not nil.
  """
  def decode(%{published_at: nil} = event) do
    %{event | published_at: nil}
  end

  def decode(%{published_at: published_at} = event) do
    {:ok, datetime, _} = DateTime.from_iso8601(published_at)
    datetime = DateTime.truncate(datetime, :second)
    %{event | published_at: datetime}
  end
end
