defmodule Franklin.Posts do
  @moduledoc """
  Business domain context for the creation and access of `Post` entities.

  This module, and the underlying architecture it is built on (see [ADR:
  CQRS](todo-add-link)), values platform availability over real-time data
  consistency and thus functions of this module that would be considered
  commands (like `create_post/1`) do not guarantee an immediate state change or
  attempt to return a current projection of state. Instead you should look to
  the notifications provided by `subscribe/0` to know when entity projections
  are finished and available through the query-specific functions like
  `get_post/1` or `list_posts/0`.
  """

  import Ecto.Query

  alias Franklin.CommandedApplication
  alias Franklin.Posts.Commands.CreatePost
  alias Franklin.Posts.Projections.Post
  alias Franklin.Repo

  @type create_attrs :: %{
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @type error_list :: %{atom() => list(String.t())}

  @doc """
  A process calling this function will be subscribed to the post-id specific topic
  """
  @spec subscribe(Ecto.UUID.t()) :: :ok
  def subscribe(post_id) do
    :ok = Phoenix.PubSub.subscribe(Franklin.PubSub, topic(post_id))
  end

  @doc """
  Broadcast the given `event_name` and `payload` to the topic name associated
  with the given `post_id`.

  Generally speaking, we do not expect other modules outside of the
  `Franklin.Posts` submodules to call this function. It is provided here so as
  to live next to the sister `subscribe/0` function, which is shared knowledge as well as to document the expected events and payload shape to help consumer who want to subscribe and react to these events

  ## Allowed Event Names:

    * `:post_created`
    * `:post_deleted`
    * `:post_updated`
  """
  def broadcast_post_event(post_id, event_name, payload) do
    Phoenix.PubSub.broadcast(
      Franklin.PubSub,
      "posts:#{id}",
      {topic(post_id), %{id: id}}
    )
  end

  @doc """
  Attempts to create a new `Post` entity using the given attributes.

  Returns `{:ok, uuid}` when successful and `{:error, list}` if there was a
  validation error.

  ## Attributes

    * `id` - (optional) An `Ecto.UUID` value that will be used as the
       identity of this post. Will be generated if not provided.
    * `title` - A string value between 3 and 50 characters in length.
    * `published_at` - A `DateTime` value representing the public-facing
       published date of the Post.

  Note: The current `title` validations are primarily in place for code
  demonstration and will be deleted eventually.

  Since the projections that support access functions like `get_post/1` or
  `list_posts/0` are async you'll probably want to lean on PubSub notifications
  using Posts.subscribe/0 and listen for events to know when the new entity is
  available.

  The error list is a map using the atom-based attribute name keys associated
  with list values containing validation descriptions.

  ## Examples:

    > iex> Posts.new(%{id: 123, published_at: nil, title: nil})
    > %{
    >   id: ["is invalid"],
    >   published_at: ["can't be blank"],
    >   title: ["can't be blank"]
    > }
  """
  @spec create_post(create_attrs()) ::
          {:ok, Ecto.UUID.t()} | {:error, :command_failure}
  def create_post(attrs) do
    case CreatePost.new(attrs) do
      {:ok, command} ->
        :ok = CommandedApplication.dispatch(command)
        {:ok, command.id}

      {:error, errors} ->
        {:error, errors}
    end
  end

  def update_post() do
    # TODO
  end

  @doc """
  Returns a Post entity related to the given id or `nil` if none is found.
  """
  @spec get_post(Ecto.UUID.t()) :: Post.t() | nil
  def get_post(id) do
    Repo.get(Post, id)
  end

  @doc """
  Returns a list of Post entities, sorted by `published_at` descending.
  """
  @spec list_posts() :: list(Post.t())
  def list_posts() do
    query = from p in Post, order_by: [desc: p.published_at]
    Repo.all(query)
  end

  defp topic(post_id) do
    "posts:#{post_id}"
  end
end
