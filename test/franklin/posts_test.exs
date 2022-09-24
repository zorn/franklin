defmodule Franklin.PostsTest do
  use Franklin.DataCase

  alias Franklin.Posts
  alias Franklin.Posts.Projections.Post

  describe fut(&Posts.subscribe_typo/1) do
    test "returns :ok when any UUID is passed in" do
      assert :ok = Posts.subscribe(Ecto.UUID.generate())
    end

    test "calling process does not receive `post_created` event notification without a previous call to `subscribe/1`" do
      uuid = Ecto.UUID.generate()
      {:ok, _} = Posts.create_post(valid_create_post_attrs(uuid))
      refute_receive {:post_created, %{id: ^uuid}}
    end

    test "calling process does receive `post_created` event notification after previous call to `subscribe/1`" do
      uuid = Ecto.UUID.generate()
      :ok = Posts.subscribe(uuid)
      {:ok, _} = Posts.create_post(valid_create_post_attrs(uuid))
      assert_receive {:post_created, %{id: ^uuid}}
    end
  end

  describe fut(&Posts.create_post/1) do
    setup :generate_identity_and_subscribe

    test "successful with valid arguments", %{uuid: uuid} do
      attrs = valid_create_post_attrs(uuid)

      assert {:ok, ^uuid} = Posts.create_post(attrs)

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

    test "failure with invalid published at", %{uuid: uuid} do
      attrs = %{
        id: uuid,
        published_at: nil,
        title: "a valid title"
      }

      assert {:error, errors} = Posts.create_post(attrs)
      assert "can't be blank" in errors.published_at
    end

    # TODO: Add a test that verifies expected outcome for a command dispatch error.
  end

  describe fut(&Posts.update_post/2) do
    setup :generate_identity_and_subscribe
    setup :create_test_post

    test "successfully can update title", %{uuid: uuid, test_post: test_post} do
      assert {:ok, ^uuid} = Posts.update_post(test_post, %{title: "new title"})
      assert_receive {:post_title_updated, %{id: ^uuid}}
      assert %Post{id: ^uuid, title: "new title"} = Posts.get_post(uuid)
    end

    test "successfully can update published_at", %{uuid: uuid, test_post: test_post} do
      assert {:ok, ^uuid} =
               Posts.update_post(test_post, %{
                 published_at: ~U[2019-08-20 13:30:00Z]
               })

      assert_receive {:post_published_at_updated, %{id: ^uuid}}

      assert %Post{
               id: ^uuid,
               published_at: ~U[2019-08-20 13:30:00Z]
             } = Posts.get_post(uuid)
    end

    test "successfully can update title and published_at at the same time, resulting in multiple broadcasts",
         %{uuid: uuid, test_post: test_post} do
      assert {:ok, ^uuid} =
               Posts.update_post(test_post, %{
                 title: "new title",
                 published_at: ~U[2019-08-20 13:30:00Z]
               })

      assert_receive {:post_title_updated, %{id: ^uuid}}
      assert_receive {:post_published_at_updated, %{id: ^uuid}}

      assert %Post{
               id: ^uuid,
               title: "new title",
               published_at: ~U[2019-08-20 13:30:00Z]
             } = Posts.get_post(uuid)
    end

    test "validate that when given an empty attribute map a success response is returned but no events are created, messages broadcasted or projections altered",
         %{uuid: uuid, test_post: test_post} do
      assert {:ok, ^uuid} = Posts.update_post(test_post, %{})
      refute_receive {:post_title_updated, %{id: ^uuid}}
      refute_receive {:post_published_at_updated, %{id: ^uuid}}
      assert test_post == Posts.get_post(uuid)
    end

    test "validate that when given unexpected attributes a success response is returned but no events are created, messages broadcasted or projections altered",
         %{uuid: uuid, test_post: test_post} do
      assert {:ok, ^uuid} = Posts.update_post(test_post, %{promoted: true})

      refute_receive {:post_title_updated, %{id: ^uuid}}
      refute_receive {:post_published_at_updated, %{id: ^uuid}}

      assert test_post == Posts.get_post(uuid)
    end

    test "validate that you can not override the id of the existing post",
         %{uuid: uuid, test_post: test_post} do
      new_uuid = Ecto.UUID.generate()
      assert {:ok, ^uuid} = Posts.update_post(test_post, %{id: new_uuid})

      refute_receive {:post_title_updated, %{id: ^uuid}}
      refute_receive {:post_published_at_updated, %{id: ^uuid}}

      assert test_post == Posts.get_post(uuid)
      assert nil == Posts.get_post(new_uuid)
    end
  end

  defp generate_identity_and_subscribe(_) do
    uuid = Ecto.UUID.generate()
    Phoenix.PubSub.subscribe(Franklin.PubSub, "posts:#{uuid}")
    %{uuid: uuid}
  end

  defp create_test_post(%{uuid: uuid} = _context) do
    {:ok, _} = Posts.create_post(valid_create_post_attrs(uuid))
    assert_receive {:post_created, %{id: ^uuid}}
    %{uuid: uuid, test_post: Posts.get_post(uuid)}
  end

  defp valid_create_post_attrs(uuid) do
    %{
      id: uuid,
      published_at: ~U[2022-08-20 13:30:00Z],
      title: "hello world"
    }
  end
end
