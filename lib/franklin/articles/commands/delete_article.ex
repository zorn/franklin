defmodule Franklin.Articles.Commands.DeleteArticle do
  @moduledoc """
  A command to represent the user-semantic intent of deleting an `Article` entity.
  """

  defstruct [:id]

  @type t :: %__MODULE__{id: Ecto.UUID.t()}
end
