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

# Make some default posts.
%CreatePost{
  uuid: Ecto.UUID.generate(),
  title: "Hello, world one!",
  published_at: ~U[2022-07-11 13:00:00Z]
}
|> CommandedApplication.dispatch()

%CreatePost{
  uuid: Ecto.UUID.generate(),
  title: "Hello, world two!",
  published_at: ~U[2022-07-12 09:00:00Z]
}
|> CommandedApplication.dispatch()
