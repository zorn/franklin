defmodule Franklin.Articles do
  import Ecto.Query
  import Franklin.Articles.Projector, only: [topic: 1]

  alias Franklin.Articles.Article
  alias Franklin.Repo
  alias Franklin.ValidationErrorMap

  @typedoc "Attribute map type relative to the `create_article/1` function."
  @type create_attrs :: %{
          required(:body) => String.t(),
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:title) => String.t()
        }

  @doc """
  Attempts to create a new `Article` entity.

  Returns `{:ok, uuid}` when successful and `{:error, validation_error_map}` if
  there was a problem.

  ## Attributes

    * `:body` - A Markdown-flavored string value no more that 100 MBs in length.
    * `:id` - (optional) An `Ecto.UUID` value that will be used as the
       identity of this article. Will be generated if not provided.
    * `:published_at` - A `DateTime` value representing the public-facing
       publication date of the article.
    * `:title` - A plain-text string value using 1 to 255 characters in length.
  """
  @spec create_article(create_attrs()) :: {:ok, Ecto.UUID.t()} | {:error, ValidationErrorMap.t()}
  def create_article(attrs) do
    case Franklin.Articles.Commands.CreateArticle.new(attrs) do
      {:ok, command} -> dispatch_command(command)
      {:error, errors} -> {:error, errors}
    end
  end

  @doc """
  Returns the `Article` entity with an identity matching the given id or
  `nil` if none is found.
  """
  @spec get_article(Ecto.UUID.t()) :: Article.t() | nil
  def get_article(id) do
    Repo.get(Article, id)
  end

  @doc """
  # Returns a list of `Article` entities sorted by `:published_at` descending.
  """
  def list_articles() do
    query = from(a in Article, order_by: [desc: a.published_at])
    Repo.all(query)
  end

  @doc """
  Subscribes the calling process to a `Phoenix.PubSub` topic relative to the
  passed in `article_id`.

  This topic will receive the following messages:

  * `{:article_created, %{id: uuid}}`
  * `{:article_deleted, %{id: uuid}}`
  * `{:article_body_updated, %{id: uuid}}`
  * `{:article_published_at_updated, %{id: uuid}}`
  * `{:article_title_updated, %{id: uuid}}`
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
