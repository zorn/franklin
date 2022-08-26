defmodule Franklin.Posts.Validations do
  @moduledoc """
  Shared validation logic for `Post`-related attributes.
  """

  import Ecto.Changeset

  @doc """
  Accepts and returns a Changeset of a `Post` and applies domain
  validation rules for the `id` attribute.
  """
  @spec validate_id(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_id(changeset) do
    validate_required(changeset, :id)
  end

  @doc """
  Accepts and returns a Changeset of a `Post` and applies domain
  validation rules for the `published_at` attribute.
  """
  @spec validate_published_at(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_published_at(changeset) do
    validate_required(changeset, :published_at)
  end

  @doc """
  Accepts and returns a Changeset of a `Post` and applies domain
  validation rules for the `title` attribute.
  """
  @spec validate_title(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_title(changeset) do
    changeset
    |> validate_required(:title)
    |> validate_length(:title, min: 3, max: 50)
  end
end
