defmodule Franklin.Articles.Events.ArticleTitleUpdated do
  @derive Jason.Encoder
  defstruct [
    :title,
    :id
  ]
end
