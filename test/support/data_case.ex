defmodule Franklin.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Franklin.DataCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Franklin.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import Franklin.DataCase
      import Commanded.Assertions.EventAssertions
      import Franklin.SmartDescribe
    end
  end

  setup tags do
    Franklin.DataCase.setup_stores(tags)

    :ok
  end

  @doc """
  Sets up the typical Ecto database sandbox (used for projections) and
  the event store (which is configured as in-memory for testing only).
  """
  def setup_stores(tags) do
    # Since we stop applications inside of `on_exit` the first thing we want to
    # do is verify they are all started.
    {:ok, _apps} = Application.ensure_all_started(:franklin)

    # Next we will start the typical Ecto sandbox like experience which will be
    # utilized for the projection persistance.
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Franklin.Repo, shared: not tags[:async])

    on_exit(fn ->
      # Clear the in memory event store.
      Commanded.EventStore.Adapters.InMemory.reset!(Franklin.CommandedApplication)

      # Stop the app in full. The reason why the app must be stopped and then
      # started between resetting the event store is to ensure all Commanded
      # application processes are restarted with their initial state to prevent
      # state from one test affecting another.
      # FIXME: How does this impact async tests?
      # I think the InMemory store is global so probably yes. :(
      :ok = Application.stop(:franklin)

      # Stop the Ecto sandbox.
      Ecto.Adapters.SQL.Sandbox.stop_owner(pid)
    end)
  end

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "password is too short" in errors_on(changeset).password
      assert %{password: ["password is too short"]} = errors_on(changeset)

  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
