defmodule Franklin.Posts.Validations do
  @moduledoc """
  Shared types and preconditions for `Post`-related values.
  """

  import Domo

  @type title :: String.t()
  precond title: &if(String.length(&1) > 1, do: :ok, else: {:error, "title is required"})
end
