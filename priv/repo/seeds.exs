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

# January Journal
journal_markdown_path = Path.expand("priv/content/2023/1/22-journal/index.md")
content = File.read!(journal_markdown_path)
{:ok, front_matter, markdown_content} = YamlFrontMatter.parse_file(journal_markdown_path)
{:ok, published_at, _utc_offset} = DateTime.from_iso8601(front_matter["date"])

%CreateArticle{
  id: Ecto.UUID.generate(),
  title: front_matter["title"],
  body: markdown_content,
  published_at: published_at
}
|> CommandedApplication.dispatch()

# Boston Trip
journal_markdown_path = Path.expand("priv/content/2023/1/boston-2022-trip/index.md")
content = File.read!(journal_markdown_path)
{:ok, front_matter, markdown_content} = YamlFrontMatter.parse_file(journal_markdown_path)
{:ok, published_at, _utc_offset} = DateTime.from_iso8601(front_matter["date"])

%CreateArticle{
  id: Ecto.UUID.generate(),
  title: front_matter["title"],
  body: markdown_content,
  published_at: published_at
}
|> CommandedApplication.dispatch()
