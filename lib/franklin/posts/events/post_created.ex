defmodule Franklin.Posts.Events.PostCreated do
  @derive Jason.Encoder
  defstruct [
    :published_at,
    :title,
    :uuid
  ]
end

alias Franklin.Posts.Events.PostCreated

defimpl Commanded.Serialization.JsonDecoder, for: PostCreated do
  @doc """
  Additional decoder logic to convert stringified `published_at`
  DateTime JSON value into an Elixir DateTime value.
  """
  def decode(%PostCreated{published_at: published_at} = event) do
    {:ok, datetime, _} = DateTime.from_iso8601(published_at)
    datetime = DateTime.truncate(datetime, :second)
    %PostCreated{event | published_at: datetime}
  end
end
