defmodule Franklin.ArticlesTest do
  use Franklin.DataCase

  alias Franklin.Articles

  describe "create_article/1" do
    test "successful with minimum valid arguments" do
      min_attrs = %{title: "t", body: "b", published_at: sample_published_at()}
      assert {:ok, uuid} = Articles.create_article(min_attrs)

      # Since we don't have the `uuid` before calling `create_article/1` we
      # can't subscribe to verify pub_sub notifications. We'll verify that more
      # so below in the maximum version.
    end

    test "successful with maximum valid arguments" do
      uuid = Ecto.UUID.generate()
      :ok = Articles.subscribe(uuid)

      max_attrs = %{
        id: uuid,
        title: title_255_length(),
        body: sample_body(),
        published_at: sample_published_at()
      }

      assert {:ok, ^uuid} = Articles.create_article(max_attrs)

      assert_receive {:article_created, %{id: ^uuid}}
      assert_receive {:article_body_updated, %{id: ^uuid}}
      assert_receive {:article_published_at_updated, %{id: ^uuid}}
      assert_receive {:article_title_updated, %{id: ^uuid}}
    end

    test "fails with no arguments" do
      assert {:error, errors} = Articles.create_article(%{})
      assert "can't be blank" in errors.published_at
      assert "can't be blank" in errors.title
      assert "can't be blank" in errors.body
    end

    test "fails with invalid id argument type" do
      assert {:error, errors} = Articles.create_article(%{id: 123})
      assert "is invalid" in errors.id
    end

    test "fails with invalid published_at argument type" do
      assert {:error, errors} = Articles.create_article(%{published_at: "today"})
      assert "is invalid" in errors.published_at
    end

    test "fails when title is too long" do
      assert {:error, errors} = Articles.create_article(%{title: title_256_length()})
      assert "should be at most 255 character(s)" in errors.title
    end

    test "fails when body is too large" do
    end
  end

  defp title_255_length() do
    String.Chars.to_string(Faker.Lorem.characters(255))
  end

  defp title_256_length() do
    String.Chars.to_string(Faker.Lorem.characters(256))
  end

  defp sample_body() do
    """
    # Heading 1

    Hello [world](https://mikezornek.com)!
    """
  end

  defp sample_published_at() do
    ~U[2022-08-20 13:30:00Z]
  end
end
