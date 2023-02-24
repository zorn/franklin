defmodule Franklin.Articles.Projector do
  use Commanded.Projections.Ecto,
    # Register a name for the handler's subscription in the event store
    name: "Franklin.Articles.Projector",
    application: Franklin.CommandedApplication

  alias Franklin.Articles.Article
  alias Franklin.Articles.Events.ArticleBodyUpdated
  alias Franklin.Articles.Events.ArticleCreated
  alias Franklin.Articles.Events.ArticleDeleted
  alias Franklin.Articles.Events.ArticlePublishedAtUpdated
  alias Franklin.Articles.Events.ArticleSlugUpdated
  alias Franklin.Articles.Events.ArticleTitleUpdated
  alias Franklin.Repo

  require Logger

  @doc """
  Returns the PubSub topic name relative to the passed in `article_id` uuid value.
  """
  def topic(article_id) do
    "article:#{article_id}"
  end

  project(
    %ArticleCreated{
      id: id,
      title: title,
      body: body,
      slug: slug,
      published_at: published_at
    },
    _,
    fn multi ->
      changeset =
        Article.insert_changeset(%Article{}, %{
          id: id,
          title: title,
          body: body,
          slug: slug,
          published_at: published_at
        })

      Ecto.Multi.insert(multi, :article, changeset)
    end
  )

  project(%ArticleDeleted{id: id}, _, fn multi ->
    Ecto.Multi.delete(multi, :article, fn _ -> %Article{id: id} end)
  end)

  project(%ArticleBodyUpdated{id: id, body: body}, _, fn multi ->
    add_changeset_to_multi(multi, get_article(id), :body, body)
  end)

  project(%ArticleSlugUpdated{id: id, slug: slug}, _, fn multi ->
    add_changeset_to_multi(multi, get_article(id), :slug, slug)
  end)

  project(%ArticlePublishedAtUpdated{id: id, published_at: published_at}, _, fn multi ->
    add_changeset_to_multi(multi, get_article(id), :published_at, published_at)
  end)

  project(%ArticleTitleUpdated{id: id, title: title}, _, fn multi ->
    add_changeset_to_multi(multi, get_article(id), :title, title)
  end)

  @impl Commanded.Projections.Ecto
  def after_update(event, _metadata, _changes) do
    case broadcast_event_completion(event) do
      {:error, error} ->
        Logger.warning("Attempt to broadcast event completion failed: #{inspect(error)}")
        {:error, error}

      :ok ->
        :ok
    end
  end

  @spec broadcast_event_completion(map()) :: :ok | {:error, term}
  defp broadcast_event_completion(%{id: id} = event) do
    Phoenix.PubSub.broadcast(Franklin.PubSub, topic(id), {broadcast_name(event), %{id: id}})
  end

  defp broadcast_name(%ArticleCreated{}), do: :article_created
  defp broadcast_name(%ArticleTitleUpdated{}), do: :article_title_updated
  defp broadcast_name(%ArticleBodyUpdated{}), do: :article_body_updated
  defp broadcast_name(%ArticleSlugUpdated{}), do: :article_slug_updated
  defp broadcast_name(%ArticlePublishedAtUpdated{}), do: :article_published_at_updated
  defp broadcast_name(%ArticleDeleted{}), do: :article_deleted

  defp get_article(id) do
    case Repo.get(Article, id) do
      nil ->
        Logger.error("#{__MODULE__}.get_article/1 unexpectedly returned nil for id: #{id}")
        nil

      article ->
        article
    end
  end

  defp add_changeset_to_multi(multi, %Article{} = article, field_name, new_value) do
    changeset = Article.update_changeset(article, %{field_name => new_value})
    Ecto.Multi.update(multi, :article, changeset)
  end

  defp add_changeset_to_multi(multi, nil, field_name, new_value) do
    Logger.error("Could not project field_name #{field_name} with new_value #{new_value}")
    multi
  end
end
