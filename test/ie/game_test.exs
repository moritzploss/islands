defmodule IE.GameTest do
  use ExUnit.Case, async: true
  alias IE.Game

  test "setup new game by starting GenServer with name of player1" do
    {:ok, pid} = Game.start_link("Test User")
    state = :sys.get_state(pid)
    name = Map.fetch!(state.player1, :name)

    assert name == "Test User"
    assert Map.has_key?(state, :player1)
    assert Map.has_key?(state, :player2)
    assert Map.has_key?(state, :rules)
  end
end
