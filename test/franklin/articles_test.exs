defmodule Franklin.ArticlesTest do
  use Franklin.DataCase

  alias Franklin.Articles
  alias Franklin.Articles.Article

  describe "create_article/1" do
    test "successful with minimum valid arguments" do
      min_attrs = %{title: "t", body: "b", published_at: sample_published_at()}
      assert {:ok, _uuid} = Articles.create_article(min_attrs)

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

  describe "list_articles/0" do
    test "returns empty list when no entities" do
      assert [] = Articles.list_articles()
    end

    test "returns an expected list of entities" do
      create_article!()
      create_article!()
      create_article!()

      list = Articles.list_articles()
      assert length(list) == 3
    end

    test "can limit returned list and the default expected sort order is honored" do
      create_article!(%{title: "January", published_at: ~U[2022-01-01 12:00:00Z]})
      create_article!(%{title: "February", published_at: ~U[2022-02-01 12:00:00Z]})
      create_article!(%{title: "March", published_at: ~U[2022-03-01 12:00:00Z]})
      create_article!(%{title: "April", published_at: ~U[2022-04-01 12:00:00Z]})
      create_article!(%{title: "May", published_at: ~U[2022-05-01 12:00:00Z]})
      create_article!(%{title: "June", published_at: ~U[2022-06-01 12:00:00Z]})

      list = Articles.list_articles(%{limit: 3})
      assert length(list) == 3

      assert [
               %Article{title: "June"},
               %Article{title: "May"},
               %Article{title: "April"}
             ] = list
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

  defp create_article!(custom_values \\ %{}) do
    attrs = required_new_article_attributes(custom_values)
    assert {:ok, uuid} = Articles.create_article(attrs)
    :ok = Articles.subscribe(uuid)

    # It's lame I have to listen for all of these.
    assert_receive {:article_created, %{id: ^uuid}}
    assert_receive {:article_title_updated, %{id: ^uuid}}
    assert_receive {:article_body_updated, %{id: ^uuid}}
    assert_receive {:article_published_at_updated, %{id: ^uuid}}
  end

  defp required_new_article_attributes(custom_values) do
    %{
      title: Map.get(custom_values, :title, "Default Title"),
      body: Map.get(custom_values, :body, "Default Body"),
      published_at: Map.get(custom_values, :published_at, DateTime.utc_now())
    }
  end
end
