defmodule Franklin.Router do
  @moduledoc """
  Router that defines which commands get sent to which aggregate.
  """

  use Commanded.Commands.Router

  alias Franklin.Articles.ArticleAggregate
  alias Franklin.Articles.Commands.CreateArticle
  alias Franklin.Articles.Commands.DeleteArticle
  alias Franklin.Articles.Commands.UpdateArticle

  dispatch([CreateArticle], to: ArticleAggregate, identity: :id)
  dispatch([DeleteArticle], to: ArticleAggregate, identity: :id)
  dispatch([UpdateArticle], to: ArticleAggregate, identity: :id)
end
