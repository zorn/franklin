defmodule Franklin.WaitForPassing do
  @moduledoc """
  Contains functions uses for testing eventual truth.
  """

  @doc """
  A simple function to assert eventual truth.

  ## Example:

  wait_for_passing(fn ->
    assert [
      %Article{title: "A valid new article title."}
    ] = Articles.list_articles()
  end)

  Accepts a timeout and a function. Inside the passed in function we expect code
  with testing assert expressions. As long as the timeout has time remaining the
  function will be ran. When the asserts fail, the process will sleep and then
  try again, decrementing the timeout. This allows us to verify that the asserts
  eventually pass.
  """
  def wait_for_passing(timeout \\ 5_000, fun)

  def wait_for_passing(timeout, fun) when timeout > 0 do
    fun.()
  rescue
    _ ->
      Process.sleep(100)
      wait_for_passing(timeout - 100, fun)
  end

  def wait_for_passing(_timeout, fun), do: fun.()
end
