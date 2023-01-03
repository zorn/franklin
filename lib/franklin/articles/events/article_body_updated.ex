defmodule Franklin.Articles.Events.ArticleBodyUpdated do
  @derive Jason.Encoder
  defstruct [
    :body,
    :id
  ]
end
