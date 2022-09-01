defmodule Franklin.Posts.Projectors.Post do
  use Commanded.Projections.Ecto,
    # Register a name for the handler's subscription in the event store
    name: "Posts.Projectors.Post",
    application: Franklin.CommandedApplication

  alias Franklin.Repo
  alias Franklin.Posts.Events.PostCreated
  alias Franklin.Posts.Events.PostDeleted
  alias Franklin.Posts.Events.PostPublishedAtUpdated
  alias Franklin.Posts.Events.PostTitleUpdated
  alias Franklin.Posts.Projections.Post

  project(%PostCreated{} = created, _, fn multi ->
    # Should this use a changeset for validation?
    Ecto.Multi.insert(multi, :post, %Post{
      id: created.id,
      title: created.title,
      published_at: created.published_at
    })
  end)

  project(%PostDeleted{id: id}, _, fn multi ->
    Ecto.Multi.delete(multi, :Post, fn _ -> %Post{id: id} end)
  end)

  project(%PostPublishedAtUpdated{id: id, published_at: published_at}, _, fn multi ->
    case Repo.get(Post, id) do
      # should a projector fail or report an error here? Would we ever accept a command to delete a post that does not exist?
      nil ->
        multi

      post ->
        Ecto.Multi.update(
          multi,
          :Post,
          Post.update_changeset(post, %{published_at: published_at})
        )
    end
  end)

  project(%PostTitleUpdated{id: id, title: title}, _, fn multi ->
    case Repo.get(Post, id) do
      nil -> multi
      post -> Ecto.Multi.update(multi, :Post, Post.update_changeset(post, %{title: title}))
    end
  end)

  @impl Commanded.Projections.Ecto
  def after_update(event, _metadata, _changes) do
    broadcast_event_completion(event)
    :ok
  end

  defp broadcast_event_completion(%{id: id} = event) do
    # FIXME: Should we broadcast anything more than the UUID?
    # FIXME: Should there be a more firm contract on the shape
    # of the broadcast payload?
    Franklin.Posts.broadcast_post_event(id, broadcast_name(event), %{id: id})
  end

  defp broadcast_name(%PostCreated{}), do: :post_created
  defp broadcast_name(%PostDeleted{}), do: :post_deleted

  # FIXME: Seems excessive to post unique event names for each attribute, are we sure `after_update` would be called for each event? or is that called after the multi is applies/saved?
  defp broadcast_name(%PostTitleUpdated{}), do: :post_title_updated
  defp broadcast_name(%PostPublishedAtUpdated{}), do: :post_published_at_updated
end
