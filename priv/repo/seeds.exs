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

defmodule SeedTools do
  def dispatch_command({:ok, command}) do
    Franklin.CommandedApplication.dispatch(command)
  end

  def dispatch_command({:error, reason}) do
    raise "Could not dispatch command: #{reason}"
  end
end

alias Franklin.Articles.Slugs
alias Franklin.Articles.Commands.CreateArticle

sample_article_markdown = """

## Headline Two

A [link](https://mikezornek.com)!

"""

CreateArticle.new(%{
  id: Ecto.UUID.generate(),
  title: "Sample Article One",
  slug: "2022/7/sample-article-one",
  body: sample_article_markdown,
  published_at: ~U[2022-07-13 09:00:00Z]
})
|> SeedTools.dispatch_command()

CreateArticle.new(%{
  id: Ecto.UUID.generate(),
  title: "Sample Article Two",
  slug: "2022/7/sample-article-two",
  body: sample_article_markdown,
  published_at: ~U[2022-07-14 09:00:00Z]
})
|> SeedTools.dispatch_command()

# January Journal
journal_markdown_path = Path.expand("priv/content/2023/1/22-journal/index.md")
content = File.read!(journal_markdown_path)
{:ok, front_matter, markdown_content} = YamlFrontMatter.parse_file(journal_markdown_path)
{:ok, published_at, _utc_offset} = DateTime.from_iso8601(front_matter["date"])
filename = journal_markdown_path |> String.replace_suffix("/index.md", "") |> Path.basename()

CreateArticle.new(%{
  id: Ecto.UUID.generate(),
  title: front_matter["title"],
  slug: Slugs.generate_slug_for_title(filename, published_at),
  body: markdown_content,
  published_at: published_at
})
|> SeedTools.dispatch_command()

# Boston Trip
journal_markdown_path = Path.expand("priv/content/2023/1/boston-2022-trip/index.md")
content = File.read!(journal_markdown_path)
{:ok, front_matter, markdown_content} = YamlFrontMatter.parse_file(journal_markdown_path)
{:ok, published_at, _utc_offset} = DateTime.from_iso8601(front_matter["date"])
filename = journal_markdown_path |> String.replace_suffix("/index.md", "") |> Path.basename()

CreateArticle.new(%{
  id: Ecto.UUID.generate(),
  title: front_matter["title"],
  slug: Slugs.generate_slug_for_title(filename, published_at),
  body: markdown_content,
  published_at: published_at
})
|> SeedTools.dispatch_command()
