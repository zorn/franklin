defmodule Franklin.Posts do
  @moduledoc """
  Business domain context for the creation and access of `Post` entities.

  This module is built using a CQRS architecture and values platform
  availability over real-time data consistency. Therefore functions in this
  module that would be considered commands (like `create_post/1`) do not
  guarantee an immediate state change or attempt to return a current projection
  of state. Instead you should look to messages provided by `subscribe/1` to
  know when entity projections are available via the query functions such as
  `get_post/1` or `list_posts/0`.
  """

  import Ecto.Query
  import Franklin.Posts.Projectors.Post, only: [topic: 1]

  alias Franklin.Posts.Projections.Post
  alias Franklin.Repo

  @typedoc "Attribute map structure relative to the `create_post/1` function."
  @type create_attrs :: %{
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @typedoc "A map structure containing field level error details."
  @type errors :: %{atom() => list(String.t())}

  @doc """
  Attempts to create a new `Post` entity using the given attributes.

  Returns `{:ok, uuid}` when successful and `{:error, errors}` if
  there was a problem.

  ## Attributes

    * `id` - (optional) An `Ecto.UUID` value that will be used as the
       identity of this post. Will be generated if not provided.
    * `title` - A string value between 3 and 50 characters in length.
    * `published_at` - A `DateTime` value representing the public-facing
       published date of the `Post`.

  Note: The current `title` validations are primarily in place for code
  demonstration and will be deleted eventually.

  The `errors` of an `{:error, errors}` response is a map where each attribute of concern is an atom-based key and the value is a list of strings describing the error.

  ## Example:

    > iex> Posts.create_post(%{id: 123, published_at: nil, title: "yo"})
    > %{
    >   id: ["is invalid"],
    >   published_at: ["can't be blank"],
    >   title: ["should be at least 3 character(s)"]
    > }
  """
  @spec create_post(create_attrs()) :: {:ok, Ecto.UUID.t()} | {:error, errors()}
  def create_post(attrs) do
    case Franklin.Posts.Commands.CreatePost.new(attrs) do
      {:ok, command} ->
        dispatch_command(command)

      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Returns a `Post` entity related to the given id or `nil` if none is found.
  """
  @spec get_post(Ecto.UUID.t()) :: Post.t() | nil
  def get_post(id) do
    Repo.get(Post, id)
  end

  @doc """
  Returns a list of `Post` entities, sorted by `published_at` descending.
  """
  @spec list_posts() :: list(Post.t())
  def list_posts() do
    query = from p in Post, order_by: [desc: p.published_at]
    Repo.all(query)
  end

  @doc """
  Subscribes the calling process to a `Phoenix.PubSub` topic relative to the
  passed in `post_id`.

  This topic will receive the following messages:

  * `{:post_created, %{id: uuid}}` - published after a `Post` has been
    created and module-specific projections are complete, thus
    enabling functions such as `get_post/1` to be successful.
  """
  @spec subscribe(Ecto.UUID.t()) :: :ok
  def subscribe(post_id) do
    :ok = Phoenix.PubSub.subscribe(Franklin.PubSub, topic(post_id))
  end

  defp dispatch_command(command) do
    case Franklin.CommandedApplication.dispatch(command) do
      :ok ->
        {:ok, command.id}

      {:error, reason} ->
        {:error, %{command_dispatch_error: inspect(reason)}}
    end
  end
end
