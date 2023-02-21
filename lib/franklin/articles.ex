defmodule Franklin.Articles do
  import Ecto.Query

  alias Franklin.Articles.Article
  alias Franklin.Repo
  alias Franklin.ValidationErrorMap

  @typedoc "Attribute map type relative to the `create_article/1` function."
  @type create_attrs :: %{
          required(:body) => String.t(),
          optional(:id) => Ecto.UUID.t(),
          required(:published_at) => DateTime.t(),
          required(:slug) => String.t(),
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
    * `:slug` - The URL fragment used to identify a single article.
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
  Returns the `Article` entity for the matching slug value or
  `nil` if none is found.
  """
  @spec get_article_by_slug(Ecto.UUID.t()) :: Article.t() | nil
  def get_article_by_slug(slug) do
    Repo.get_by(Article, slug: slug)
  end

  @doc """
  # Returns a list of `Article` entities sorted by `:published_at` descending.
  """
  def list_articles(criteria \\ %{}) do
    limit = Map.get(criteria, :limit, nil)

    query =
      from(a in Article, order_by: [desc: a.published_at])
      |> add_limit(limit)

    Repo.all(query)
  end

  defp add_limit(query, limit) when is_integer(limit) do
    limit(query, ^limit)
  end

  defp add_limit(query, _), do: query

  @doc """
  Subscribes the calling process to a `Phoenix.PubSub` topic relative to the
  passed in `article_id`.

  This topic will receive the following messages:

  * `{:article_created, %{id: uuid}}`
  * `{:article_deleted, %{id: uuid}}`
  * `{:article_body_updated, %{id: uuid}}`
  * `{:article_slug_updated, %{id: uuid}}`
  * `{:article_published_at_updated, %{id: uuid}}`
  * `{:article_title_updated, %{id: uuid}}`
  """
  @spec subscribe(Ecto.UUID.t()) :: :ok | {:error, term()}
  def subscribe(article_id) do
    Phoenix.PubSub.subscribe(Franklin.PubSub, Franklin.Articles.Projector.topic(article_id))
  end

  # FIXME: Add `unsubscribe/1`.
  # https://github.com/zorn/franklin/issues/92

  @typedoc "Attribute map type relative to the `update_article/2` function."
  @type update_attrs :: %{
          optional(:body) => String.t(),
          optional(:published_at) => DateTime.t(),
          optional(:title) => String.t(),
          optional(:slug) => String.t()
        }

  @doc """
  Attempts to update the given `Article` entity.

  Returns `{:ok, uuid}` when successful and `{:error, validation_error_map}` if
  there was a problem.

  ## Attributes

    * `:body` - A Markdown-flavored string value no more that 100 MBs in length.
    * `published_at` - A `DateTime` value representing the public-facing
       published date of the article.
    * `:title` - A plain-text string value using 1 to 255 characters in length.
  """
  @spec update_article(Article.t(), update_attrs()) ::
          {:ok, Ecto.UUID.t()} | {:error, ValidationErrorMap.t()}
  def update_article(%Article{} = article, attrs) do
    command_attrs =
      attrs
      |> Map.put(:id, article.id)
      |> Map.put_new(:body, article.body)
      |> Map.put_new(:published_at, article.published_at)
      |> Map.put_new(:title, article.title)
      |> Map.put_new(:slug, article.slug)

    case Franklin.Articles.Commands.UpdateArticle.new(command_attrs) do
      {:ok, command} -> dispatch_command(command)
      {:error, errors} -> {:error, errors}
    end
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
