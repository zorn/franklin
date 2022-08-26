defmodule Franklin.PostsTest do
  use Franklin.DataCase

  alias Franklin.Posts
  alias Franklin.Posts.Projections.Post

  describe "create_post/3" do
    setup :generate_identity_and_subscribe

    test "successful with valid arguments", %{uuid: uuid} do
      attrs = %{
        id: uuid,
        published_at: ~U[2022-08-20 13:30:00Z],
        title: "hello world"
      }

      assert {:ok, ^uuid} = Posts.create_post(attrs)

      # TODO: Should we move the verification of the pubsub to something else? Feels like scope creep for this single test
      assert_receive {:post_created, %{id: ^uuid}}

      assert %Post{
               id: ^uuid,
               title: "hello world",
               published_at: ~U[2022-08-20 13:30:00Z]
             } = Posts.get_post(uuid)
    end

    test "fails with invalid arguments" do
      attrs = %{id: 123, published_at: nil, title: nil}

      assert {:error, errors} = Posts.create_post(attrs)
      assert "is invalid" in errors.id
      assert "can't be blank" in errors.published_at
      assert "can't be blank" in errors.title
    end

    test "fails when title is too short", %{uuid: uuid} do
      attrs = %{
        id: uuid,
        published_at: ~U[2022-08-20 13:30:00Z],
        title: "hi"
      }

      assert {:error, errors} = Posts.create_post(attrs)
      assert "should be at least 3 character(s)" in errors.title
    end

    test "fails when title is too long", %{uuid: uuid} do
      attrs = %{
        id: uuid,
        published_at: ~U[2022-08-20 13:30:00Z],
        title: "a really long title that is well over the fifty character limit"
      }

      assert {:error, errors} = Posts.create_post(attrs)
      assert "should be at most 50 character(s)" in errors.title
    end

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
