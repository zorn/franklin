defmodule Franklin.Posts.Validations do
  @moduledoc """
  Shared types and preconditions for `Post`-related values.
  """

  import Domo
  import Ecto.Changeset

  @type title :: String.t()
  precond title:
            &if(String.length(&1) > 5,
              do: :ok,
              else: {:error, "title can only be 5 characters in length"}
            )

  def validate_id(changeset) do
    validate_required(changeset, :id)
  end

  @spec validate_published_at(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def validate_published_at(changeset) do
    validate_required(changeset, :published_at)
  end

  @doc """
  Sharable validation rules for the title of a Post.
  """
  def validate_title(changeset) do
    changeset
    |> validate_required(:title)
    |> validate_length(:title, min: 3, max: 50)
  end
end
