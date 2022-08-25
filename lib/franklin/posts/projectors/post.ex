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
      uuid: created.uuid,
      title: created.title,
      published_at: created.published_at
    })
  end)

  project(%PostDeleted{uuid: uuid}, _, fn multi ->
    Ecto.Multi.delete(multi, :Post, fn _ -> %Post{uuid: uuid} end)
  end)

  project(%PostPublishedAtUpdated{uuid: uuid, published_at: published_at}, _, fn multi ->
    case Repo.get(Post, uuid) do
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

  project(%PostTitleUpdated{uuid: uuid, title: title}, _, fn multi ->
    case Repo.get(Post, uuid) do
      nil -> multi
      post -> Ecto.Multi.update(multi, :Post, Post.update_changeset(post, %{title: title}))
    end
  end)

  @impl Commanded.Projections.Ecto
  def after_update(event, _metadata, _changes) do
    broadcast_event_completion(event)
    :ok
  end

  defp broadcast_event_completion(%{uuid: uuid} = event) do
    # FIXME: Should we broadcast anything more than the UUID?
    # FIXME: Should there be a more firm contract on the shape
    # of the broadcast payload?
    Phoenix.PubSub.broadcast(
      Franklin.PubSub,
      "posts:#{uuid}",
      {broadcast_name(event), %{uuid: uuid}}
    )
  end

  defp broadcast_name(%PostCreated{}), do: :post_created
  defp broadcast_name(%PostDeleted{}), do: :post_deleted
  defp broadcast_name(%PostTitleUpdated{}), do: :post_title_updated
  defp broadcast_name(%PostPublishedAtUpdated{}), do: :post_published_at_updated
end
