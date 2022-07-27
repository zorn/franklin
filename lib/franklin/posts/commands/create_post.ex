defmodule Franklin.Posts.Commands.CreatePost do
  defstruct [
    :published_at,
    :title,
    :uuid
  ]

  # TODO: We might want to make a more explcit `new/1` constructor so that we can enforce turncation of published at at the command level since that is the max resolution we are insterested in storing.
end
