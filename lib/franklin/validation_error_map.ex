defmodule Franklin.ValidationErrorMap do
  @type t :: %{atom() => list(String.t())}

  @doc """
  Given an `Ecto.Changeset`, returns a `Franklin.ValidationErrorMap`
  expressing the errors in a more accessible format.

  ## Example:

  > iex> format_errors(changeset)
  > %{
  >   id: ["is invalid"],
  >   published_at: ["can't be blank"],
  >   title: ["should be at least 3 character(s)"]
  > }
  """
  @spec new(Ecto.Changeset.t()) :: t()
  def new(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
