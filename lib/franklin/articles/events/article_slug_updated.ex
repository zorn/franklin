defmodule Franklin.Articles.Events.ArticleSlugUpdated do
  @derive Jason.Encoder
  defstruct [
    :slug,
    :id
  ]
end
