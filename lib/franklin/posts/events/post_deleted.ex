defmodule Franklin.Posts.Events.PostDeleted do
  @derive Jason.Encoder
  defstruct [
    :uuid
  ]
end
