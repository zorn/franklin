defmodule Franklin.Posts.Events.PostPublishedAtUpdated do
  @derive Jason.Encoder
  defstruct [
    :published_at,
    :id
  ]
end

alias Franklin.Posts.Events.PostPublishedAtUpdated

defimpl Commanded.Serialization.JsonDecoder, for: PostPublishedAtUpdated do
  @doc """
  Additional decoder logic to convert stringified `published_at`
  DateTime JSON value into an Elixir DateTime value.
  """
  def decode(%PostPublishedAtUpdated{published_at: published_at} = event) do
    {:ok, datetime, _} = DateTime.from_iso8601(published_at)
    %PostPublishedAtUpdated{event | published_at: datetime}
  end
end
