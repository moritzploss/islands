defmodule IslandsInterfaceWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use IslandsInterfaceWeb.ChannelCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  import Ecto


  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint IslandsInterfaceWeb.Endpoint

      setup do
        start_game = fn ->
            {:ok, _, socket} = subscribe_and_join(
              socket("socket_id", %{}),
              IslandsInterfaceWeb.GameChannel,
              "game:#{Ecto.UUID.generate}"
            )
            push(socket, "new_game")
            push(socket, "add_player", "player 2")
            {:ok, socket}
        end
        {:ok, start_game: start_game}
      end
    end
  end
end
