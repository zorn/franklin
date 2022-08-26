defmodule Franklin.Posts do
  @moduledoc """
  Business context to allow for the creation and access of Post entities.
  """

  import Ecto.Query

  require Logger

  alias Franklin.CommandedApplication
  alias Franklin.Posts.Commands.CreatePost
  alias Franklin.Posts.Projections.Post
  alias Franklin.Repo
  alias Franklin.Posts.Validations

  @type create_attrs :: %{
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @type error_list :: %{atom() => list(String.t())}

  @doc """
  Attempts to create a new `Post` entity using the given attributes.

  Returns `{:ok, uuid}` when successful and `{:error, list}` if there was a validation error.

  ## Attributes

    * `id` - (optional) An `Ecto.UUID` value that will be used as the
       identity of this post. Will be generated if not provided.
    * `title` - A string value between 3 and 50 characters in length.
    * `published_at` - A `DateTime` value.

  Note: The current `title` validations are primarily in place for code demonstration and will be deleted soon™.

  Since the projections that support access functions like `get_post/1` or
  `list_posts/0` are async you'll probably want to lean on PubSub notifications
  using Posts.subscribe/0 and listen for events to know when the new entity is
  available.

  The error list is a map using the attribute atom

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

  @spec get_post(Ecto.UUID.t()) :: Post.t() | nil
  def get_post(id) do
    Repo.get(Post, id)
  end

  @spec list_posts() :: list(Post.t())
  def list_posts() do
    query = from p in Post, order_by: [desc: p.published_at]
    Repo.all(query)
  end
end
