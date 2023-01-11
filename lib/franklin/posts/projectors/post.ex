defmodule Franklin.Posts.Projectors.Post do
  use Commanded.Projections.Ecto,
    # Register a name for the handler's subscription in the event store
    name: "Posts.Projectors.Post",
    application: Franklin.CommandedApplication

  alias Franklin.Posts.Events.PostCreated
  alias Franklin.Posts.Events.PostDeleted
  alias Franklin.Posts.Events.PostPublishedAtUpdated
  alias Franklin.Posts.Events.PostTitleUpdated
  alias Franklin.Posts.Projections.Post
  alias Franklin.Repo

  @doc """
  Returns the PubSub topic name relative to the passed in `post_id` uuid value.
  """
  # FIXME: We should consider adding a formal boundary to prevent modules
  # outside the `Franklin.Posts` scope from calling this function.
  def topic(post_id) do
    "posts:#{post_id}"
  end

  project(%PostCreated{} = created, _, fn multi ->
    # Should this use a changeset for validation?
    Ecto.Multi.insert(multi, :post, %Post{
      id: created.id,
      title: created.title,
      published_at: created.published_at
    })
  end)

  project(%PostDeleted{id: id}, _, fn multi ->
    Ecto.Multi.delete(multi, :post, fn _ -> %Post{id: id} end)
  end)

  project(%PostPublishedAtUpdated{id: id, published_at: published_at}, _, fn multi ->
    case Repo.get(Post, id) do
      # should a projector fail or report an error here? Would we ever accept a command
      # to delete a post that does not exist?
      nil ->
        multi

      post ->
        Ecto.Multi.update(
          multi,
          :post,
          Post.update_changeset(post, %{published_at: published_at})
        )
    end
  end)

  project(%PostTitleUpdated{id: id, title: title}, _, fn multi ->
    case Repo.get(Post, id) do
      nil -> multi
      post -> Ecto.Multi.update(multi, :post, Post.update_changeset(post, %{title: title}))
    end
  end)

  @impl Commanded.Projections.Ecto
  def after_update(event, _metadata, _changes) do
    # FIXME: Should we match :ok here or should we maybe capture the possible error and fail broadcasting silently?
    :ok = broadcast_event_completion(event)
  end

  defp broadcast_event_completion(%{id: id} = event) do
    # FIXME: Should we broadcast anything more than the UUID?
    # FIXME: Should there be a more firm contract on the shape
    # of the broadcast payload?
    # FIXME: Should we broadcast each part of a Post mutation? Could be loud on
    # the client end -- when all the client wants is a final notification that
    # the update is "done".
    Phoenix.PubSub.broadcast(
      Franklin.PubSub,
      topic(id),
      {broadcast_name(event), %{id: id}}
    )
  end

  defp broadcast_name(%PostCreated{}), do: :post_created
  defp broadcast_name(%PostTitleUpdated{}), do: :post_title_updated
  defp broadcast_name(%PostPublishedAtUpdated{}), do: :post_published_at_updated

  # FIXME: Seems excessive to post unique event names for each attribute, are we sure `after_update` would be called
  # FIXME: for each event? or is that called after the multi is applies/saved?
  # FIXME: Commenting out until we fully build out update and delete
  # defp broadcast_name(%PostDeleted{}), do: :post_deleted
end
