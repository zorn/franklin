defmodule Franklin.Articles.ArticleAggregate do
  defstruct [
    :body,
    :id,
    :published_at,
    :slug,
    :title
  ]

  alias Franklin.Articles.ArticleAggregate, as: Article

  alias Franklin.Articles.Commands.CreateArticle
  alias Franklin.Articles.Commands.DeleteArticle
  alias Franklin.Articles.Commands.UpdateArticle

  alias Franklin.Articles.Events.ArticleBodyUpdated
  alias Franklin.Articles.Events.ArticleCreated
  alias Franklin.Articles.Events.ArticleDeleted
  alias Franklin.Articles.Events.ArticlePublishedAtUpdated
  alias Franklin.Articles.Events.ArticleSlugUpdated
  alias Franklin.Articles.Events.ArticleTitleUpdated

  def execute(
        %Article{id: nil},
        %CreateArticle{
          id: id,
          title: title,
          slug: slug,
          body: body,
          published_at: published_at
        }
      ) do
    create_event = %ArticleCreated{id: id}

    title_event = title && %ArticleTitleUpdated{id: id, title: title}
    body_event = body && %ArticleBodyUpdated{id: id, body: body}
    slug_event = body && %ArticleSlugUpdated{id: id, slug: slug}

    published_at_event =
      published_at && %ArticlePublishedAtUpdated{id: id, published_at: published_at}

    [
      create_event,
      title_event,
      body_event,
      slug_event,
      published_at_event
    ]
    |> Enum.reject(&is_nil/1)
  end

  def execute(%Article{id: id}, %DeleteArticle{id: id}) do
    %ArticleDeleted{id: id}
  end

  def execute(%Article{} = article, %UpdateArticle{} = update) do
    title_event =
      if article.title != update.title and not is_nil(update.title),
        do: %ArticleTitleUpdated{id: article.id, title: update.title}

    body_event =
      if article.body != update.body and not is_nil(update.body),
        do: %ArticleBodyUpdated{id: article.id, body: update.body}

    slug_event =
      if article.slug != update.slug and not is_nil(update.slug),
        do: %ArticleSlugUpdated{id: article.id, slug: update.slug}

    published_at_event =
      if article.published_at != update.published_at and not is_nil(update.published_at),
        do: %ArticlePublishedAtUpdated{id: article.id, published_at: update.published_at}

    [
      title_event,
      body_event,
      slug_event,
      published_at_event
    ]
    |> Enum.reject(&is_nil/1)
  end

  def apply(%Article{} = article, %ArticleCreated{} = created) do
    %Article{article | id: created.id}
  end

  def apply(%Article{id: id}, %ArticleDeleted{id: id}) do
    nil
  end

  def apply(%Article{} = article, %ArticleTitleUpdated{title: title}) do
    %Article{article | title: title}
  end

  def apply(%Article{} = article, %ArticleBodyUpdated{body: body}) do
    %Article{article | body: body}
  end

  def apply(%Article{} = article, %ArticleSlugUpdated{slug: slug}) do
    %Article{article | slug: slug}
  end

  def apply(%Article{} = article, %ArticlePublishedAtUpdated{published_at: published_at}) do
    %Article{article | published_at: published_at}
  end
end
