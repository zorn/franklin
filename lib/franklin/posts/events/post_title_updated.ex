defmodule Franklin.Posts.Events.PostTitleUpdated do
  @derive Jason.Encoder
  defstruct [
    :title,
    :uuid
  ]
end
