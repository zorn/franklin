defmodule Franklin.ArrangeArticleHelpers do
  @moduledoc """
  A collection of functions that abstract the common domain noun arrangement
  functions seen at the beginning of a test.
  """
  import Franklin.WaitForPassing

  alias Franklin.Articles

  @doc """
  Creates and returns a new article, raising an exception on failure.

  Attributes for this new article are provided by the incoming `custom_attributes` map alongside the `required_new_article_attributes/1`   mixing default required attributes alongside custom attributes.
  """
  def create_article!(custom_attributes \\ %{}) do
    attrs = required_new_article_attributes(custom_attributes)
    {:ok, uuid} = Articles.create_article(attrs)

    wait_for_passing(fn ->
      {:ok, article} = Articles.fetch_article(uuid)

      for field <- Map.keys(attrs) do
        attr_value = Map.get(attrs, field)
        article_value = Map.get(article, field)
        ^attr_value = article_value
      end

      article
    end)
  end

  defp required_new_article_attributes(custom_values) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    %{
      title: Map.get(custom_values, :title, "Default Title"),
      body: Map.get(custom_values, :body, "Default Body"),
      slug: Map.get(custom_values, :slug, "#{Ecto.UUID.generate()}/"),
      published_at: Map.get(custom_values, :published_at, now)
    }
  end
end
