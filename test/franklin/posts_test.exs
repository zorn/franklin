defmodule Franklin.PostsTest do
  use Franklin.DataCase

  alias Franklin.Posts
  alias Franklin.Posts.Projections.Post

  describe "create_post/3" do
    setup :generate_identity_and_subscribe

    test "successful with valid data", %{uuid: uuid} do
      assert {:ok, ^uuid} =
               Posts.create_post(
                 uuid,
                 "hello world",
                 ~U[2022-08-20 13:30:00Z]
               )

      assert_receive {:post_created, %{uuid: ^uuid}}

      assert %Post{
               uuid: ^uuid,
               title: "hello world",
               published_at: ~U[2022-08-20 13:30:00Z]
             } = Posts.get_post(uuid)
    end

    test "failure with invalid uuid" do
      assert {:error, "title is required; published_at is required"} =
               Posts.create_post(123, nil, nil)
    end

    # test "failure with invalid title", %{uuid: uuid} do
    #   assert {:ok, nil} = Posts.create_post(uuid, "", ~U[2022-08-20 13:30:00Z])
    # end

    # test "failure with invalid published at", %{uuid: uuid} do
    #   assert {:ok, nil} = Posts.create_post(uuid, "hello", nil)
    # end
  end

  defp generate_identity_and_subscribe(_) do
    uuid = Ecto.UUID.generate()
    Phoenix.PubSub.subscribe(Franklin.PubSub, "posts:#{uuid}")
    %{uuid: uuid}
  end

  # test "demo" do
  #   # FIXME: Should use Elixir UUID over Ecto.UUID?
  #   uuid = Ecto.UUID.generate()

  #   # Start listening for pubsub event related to this identity
  #   Phoenix.PubSub.subscribe(Franklin.PubSub, "posts:#{uuid}")

  #   # issue command to create post
  #   assert {:ok, ^uuid} = Posts.create_post(uuid, "hello", DateTime.utc_now())

  #   # by the end of the test we should have (within a timeout) been told the projectors are all done.
  #   assert_receive {:post_updated, %{uuid: ^uuid}}

  #   assert [%Post{uuid: ^uuid, title: "hello"}] = Franklin.Posts.list_posts()
  # end
end
