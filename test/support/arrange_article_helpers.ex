defmodule Franklin.ArrangeArticleHelpers do
  @moduledoc """
  A collection of functions that abstract the common domain noun arrangement
  type of functions seen at the beginning of a test.
  """
  import Franklin.WaitForPassing

  alias Franklin.Articles
  alias Franklin.Articles.Article

  @doc """
  Creates and a new article, raising an exception on failure.

  Attributes for this new article are provided by the incoming `custom_attributes` map alonside the `required_new_article_attributes/1`   mixing default required attributes alongside custom attributes

  raising an exception
  """
  def create_article!(custom_attributes \\ %{}) do
    attrs = required_new_article_attributes(custom_attributes)
    {:ok, uuid} = Articles.create_article(attrs)

    wait_for_passing(fn ->
      %Article{} = article = Articles.get_article(uuid)

      for field <- Map.keys(attrs) do
        true == match?(field, Map.get(article, field))
      end
    end)

    # :ok = Articles.subscribe(uuid)

    # # It's lame I have to listen for all of these.
    # assert_receive {:article_created, %{id: ^uuid}}
    # assert_receive {:article_title_updated, %{id: ^uuid}}
    # assert_receive {:article_body_updated, %{id: ^uuid}}
    # assert_receive {:article_published_at_updated, %{id: ^uuid}}

    %Article{} = Articles.get_article(uuid)
  end

  defp required_new_article_attributes(custom_values) do
    %{
      title: Map.get(custom_values, :title, "Default Title"),
      body: Map.get(custom_values, :body, "Default Body"),
      published_at: Map.get(custom_values, :published_at, DateTime.utc_now())
    }
  end
end
