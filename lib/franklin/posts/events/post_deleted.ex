defmodule Franklin.Posts.Events.PostDeleted do
  @derive Jason.Encoder
  defstruct [
    :id
  ]
end
