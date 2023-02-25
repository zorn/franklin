defmodule Franklin.DateTimeFormatter do
  @moduledoc """
  Functions that help format DateTime values into common formats that are not
  supplied by the standard library.
  """

  @doc """
  Returns a string representation of the given `DateTime` value in the format
  expected by the RFC 2822 specification.
  """
  @spec to_rfc_2822(DateTime.t()) :: String.t()
  def to_rfc_2822(%DateTime{} = datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%M:%S %z")
  end
end
