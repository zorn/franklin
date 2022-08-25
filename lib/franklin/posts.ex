defmodule Franklin.Posts do
  @moduledoc """
  Business context to allow for the creation and access of Post entities.
  """

  import Ecto.Query

  alias Franklin.CommandedApplication
  alias Franklin.Posts.Commands.CreatePost
  alias Franklin.Posts.Projections.Post
  alias Franklin.Repo
  alias Franklin.Posts.Validations

  @spec create_post(Ecto.UUID.t(), Validations.title(), DateTime.t()) ::
          {:ok, Ecto.UUID.t()} | {:error, String.t()}
  def create_post(identity, title, published_at) do
    # TODO: Allow nil identity and we'll generate it
    # TODO: maybe for consistency in patterns accept a fields map and then pull own what we want, and what is optional
    # replace with .new and catch error?

    case CreatePost.new(
           published_at: published_at,
           title: title,
           uuid: identity,
           maybe_filter_precond_errors: true
         ) do
      {:ok, command} ->
        case CommandedApplication.dispatch(command) do
          :ok ->
            {:ok, identity}

          error ->
            error
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_post(Ecto.UUID.t()) :: Post.t() | nil
  def get_post(id) do
    Repo.get(Post, id)
  end

  def list_posts() do
    query = from p in Post, order_by: [desc: p.published_at]
    Repo.all(query)
  end
end
