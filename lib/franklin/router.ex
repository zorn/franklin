defmodule Franklin.Router do
  @moduledoc """
  Router that defines which commands get sent to which aggregate.
  """

  use Commanded.Commands.Router

  alias Franklin.Posts.Aggregates.Post, as: PostAggregate
  alias Franklin.Posts.Commands.CreatePost
  alias Franklin.Posts.Commands.DeletePost
  alias Franklin.Posts.Commands.UpdatePost

  dispatch([CreatePost], to: PostAggregate, identity: :id)
  dispatch([DeletePost], to: PostAggregate, identity: :id)
  dispatch([UpdatePost], to: PostAggregate, identity: :id)
end
