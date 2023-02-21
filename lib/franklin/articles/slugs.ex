defmodule Franklin.Articles.Slugs do
  @moduledoc """
  Provides functions for generating the blog's slug format.
  """

  @type failure_reason :: :empty_title | :title_slugification_failed

  @doc """
  Returns a URL safe slug for the given title and published_at DateTime value.

  ## Examples

      iex> Slugs.generate_slug_for_title("Hello World!", ~U[2022-01-12 00:01:00.00Z])
      {:ok, "2022/1/hello-world/"}

      iex> Slugs.generate_slug_for_title("", ~U[2022-01-12 00:01:00.00Z])
      {:error, :empty_title}

      iex> Slugs.generate_slug_for_title("🤷‍♂️", ~U[2022-01-12 00:01:00.00Z])
      {:error, :title_slugification_failed}

  """
  @spec generate_slug_for_title(String.t(), DateTime.t()) ::
          {:ok, String.t()} | {:error, failure_reason}
  def generate_slug_for_title(title, _published_at) when title in [nil, ""] do
    {:error, :empty_title}
  end

  def generate_slug_for_title(title, %DateTime{} = published_at) do
    case Slug.slugify(title) do
      nil ->
        {:error, :title_slugification_failed}

      slugged_title ->
        time_component = Calendar.strftime(published_at, "%Y/%-m")
        {:ok, "#{time_component}/#{slugged_title}/"}
    end
  end
end
