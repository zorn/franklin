defmodule Franklin.Articles.Events.ArticlePublishedAtUpdated do
  @derive Jason.Encoder
  defstruct [
    :published_at,
    :id
  ]
end

defimpl Commanded.Serialization.JsonDecoder, for: __MODULE__ do
  @doc """
  Logic to convert string-based `published_at` JSON value into
  an Elixir DateTime value.
  """
  def decode(%{published_at: published_at} = event) do
    {:ok, datetime, _} = DateTime.from_iso8601(published_at)
    datetime = DateTime.truncate(datetime, :second)
    %{event | published_at: datetime}
  end
end
