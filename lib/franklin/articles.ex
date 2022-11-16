defmodule Franklin.Articles do
  import Ecto.Query
  import Franklin.Articles.Projector, only: [topic: 1]

  alias Franklin.Articles.Article
  alias Franklin.Repo

  @typedoc """
  A map structure containing attribute specific error details.

  ## Example:

  > %{
  >   id: ["is invalid"],
  >   published_at: ["can't be blank"],
  >   title: ["should be at least 3 character(s)"]
  > }

  """
  @type errors :: %{atom() => list(String.t())}

  @typedoc "Attribute map type relative to the `create_article/1` function."
  @type create_attrs :: %{
          optional(:id) => Ecto.UUID.t(),
          required(:body) => String.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  # FIXME: It is very repeativive that this module's `create_article/1` almost 1:1 maps to the commmand arguments. Is there any way we can inject the docs based on what is defined in the command?

  @doc """
  Attempts to create a new `Article` entity using the given attributes.

  Returns `{:ok, uuid}` when successful and `{:error, errors}` if
  there was a problem. See the `errors()` typedoc for details.

  ## Attributes

    * `id` - (optional) An `Ecto.UUID` value that will be used as the
       identity of this post. Will be generated if not provided.
    * `title` - A plain-text string value using 1 to 255 characters in length.
    * `body` - A Markdown-flavored string value no more that 100 MBs in length.
    * `published_at` - A `DateTime` value representing the public-facing
       published date of the `Post`.
  """
  @spec create_article(create_attrs()) :: {:ok, Ecto.UUID.t()} | {:error, errors()}
  def create_article(attrs) do
    case Franklin.Articles.Commands.CreateArticle.new(attrs) do
      {:ok, command} -> dispatch_command(command)
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Returns a `Article` entity related to the given id or `nil` if none is found.
  """
  @spec get_article(Ecto.UUID.t()) :: Article.t() | nil
  def get_article(id) do
    Repo.get(Article, id)
  end

  def list_articles() do
    query = from(a in Article, order_by: [desc: a.published_at])
    Repo.all(query)
  end

  @doc """
  Subscribes the calling process to a `Phoenix.PubSub` topic relative to the
  passed in `article_id`.

  This topic will receive the following messages:

  * `{:article_created, %{id: uuid}}`
  * `{:article_title_updated, %{id: uuid}}`
  * `{:article_published_at_updated, %{id: uuid}}`
  """
  @spec subscribe(Ecto.UUID.t()) :: :ok | {:error, term()}
  def subscribe(article_id) do
    Phoenix.PubSub.subscribe(Franklin.PubSub, topic(article_id))
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
