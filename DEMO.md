# DEMO

Quick little sample code to test out the event system.

Start the server with `iex -S mix phx.server`.

```elixir
alias Franklin.CommandedApplication
alias Franklin.Posts.Aggregates.Post
alias Franklin.Posts.Commands.CreatePost
alias Franklin.Posts.Commands.UpdatePost
alias Franklin.Posts.Commands.DeletePost

# Generate an ID for the post
uuid = Ecto.UUID.generate()
now = DateTime.utc_now() |> DateTime.truncate(:second)

# Create a command instance
command = %CreatePost{uuid: uuid, title: "Hello, world!", published_at: now}

# Run the command, which is dispatched to the aggregate via the router
CommandedApplication.dispatch(command)

# Query for the aggregate state
CommandedApplication.aggregate_state(Post, uuid)

# Result should be:
# %Franklin.Posts.Aggregates.Post{
#   published_at: ~U[2022-07-17 18:04:53.088870Z],
#   title: "Hello, world!",
#   uuid: "ad5924ea-dc47-4087-aa90-bafc844424de"
# }

{:ok, past} = DateTime.new(~D[2016-05-24], ~T[13:26:08.003], "Etc/UTC")

update_command = %UpdatePost{uuid: uuid, title: "Hello, demo!", published_at: past}

CommandedApplication.dispatch(update_command)

CommandedApplication.aggregate_state(Post, uuid)

delete_command = %DeletePost{uuid: uuid}

CommandedApplication.dispatch(delete_command)

CommandedApplication.aggregate_state(Post, uuid)


```
