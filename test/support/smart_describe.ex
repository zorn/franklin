defmodule Franklin.SmartDescribe do
  @doc """
  Returns a string representation for the given Function Under Test.

  When the function can not be verified as valid, raises a
  "function not found" error.
  """
  def fut(f) when is_function(f) do
    with info <- Function.info(f),
         module <- Keyword.get(info, :module),
         function <- Keyword.get(info, :name),
         arity <- Keyword.get(info, :arity),
         true <- function_exported?(module, function, arity) do
      inspect(f)
    else
      _ -> raise "function not found: #{inspect(f)}"
    end
  end
end
