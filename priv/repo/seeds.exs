# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Franklin.Repo.insert!(%Franklin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Franklin.CommandedApplication
alias Franklin.Posts.Commands.CreatePost
alias Franklin.Articles.Commands.CreateArticle

sample_article_markdown = """

## Headline Two

A [link](https://mikezornek.com)!

"""

# Make some default posts.
%CreatePost{
  id: Ecto.UUID.generate(),
  title: "Hello, world one!",
  published_at: ~U[2022-07-11 13:00:00Z]
}
|> CommandedApplication.dispatch()

%CreatePost{
  id: Ecto.UUID.generate(),
  title: "Hello, world two!",
  published_at: ~U[2022-07-12 09:00:00Z]
}
|> CommandedApplication.dispatch()

%CreateArticle{
  id: Ecto.UUID.generate(),
  title: "Sample Article One",
  body: sample_article_markdown,
  published_at: ~U[2022-07-13 09:00:00Z]
}
|> CommandedApplication.dispatch()

%CreateArticle{
  id: Ecto.UUID.generate(),
  title: "Sample Article Two",
  body: sample_article_markdown,
  published_at: ~U[2022-07-14 09:00:00Z]
}
|> CommandedApplication.dispatch()
