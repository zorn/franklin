defmodule Franklin.Articles.Slugs do
  # TODO: Add doctests
  # TODO: refactor as :ok / :error tuple

  @doc """
  Returns a URL safe slug for the given title and published_at DateTime value.

  ## Examples
      iex> generate_slug_for_title("Hello World!", ~U[2022-01-12 00:01:00.00Z])
      "2022/1/hello-world"

  """
  def generate_slug_for_title(title, published_at) when title in [nil, ""] do
    generate_slug_for_title("title", published_at)
  end

  def generate_slug_for_title(title, %DateTime{} = published_at) do
    time_component = Calendar.strftime(published_at, "%Y/%-m")

    case Slug.slugify(title) do
      nil ->
        "#{time_component}/title/"

      slugged_title ->
        "#{time_component}/#{slugged_title}/"
    end
  end

  def generate_slug_for_title(_, _), do: "title/"
end
