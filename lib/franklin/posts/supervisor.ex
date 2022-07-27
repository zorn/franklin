defmodule Franklin.Posts.Supervisor do
  use Supervisor

  alias Franklin.Posts

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Posts.Projectors.Post
      ],
      strategy: :one_for_one
    )
  end
end
