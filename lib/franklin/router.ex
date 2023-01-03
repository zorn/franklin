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

  alias Franklin.Posts.Aggregates.Post, as: PostAggregate
  alias Franklin.Posts.Commands.CreatePost
  alias Franklin.Posts.Commands.DeletePost
  alias Franklin.Posts.Commands.UpdatePost

  dispatch([CreatePost], to: PostAggregate, identity: :id)
  dispatch([DeletePost], to: PostAggregate, identity: :id)
  dispatch([UpdatePost], to: PostAggregate, identity: :id)
end
