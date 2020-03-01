defmodule IE.GameTest do
  use ExUnit.Case, async: true
  alias IE.Game

  test "setup new game by starting GenServer with name of player1" do
    {:ok, pid} = Game.start_link("Player 1")
    state = :sys.get_state(pid)

    assert state.player1.name == "Player 1"
    assert Map.has_key?(state, :player1)
    assert Map.has_key?(state, :player2)
    assert Map.has_key?(state, :rules)
  end

  test "add player2 to game" do
    {:ok, game} = Game.start_link("Player 1")
    :ok = Game.add_player2(game, "Player 2")
    state = :sys.get_state(game)

    assert state.player2.name == "Player 2"
  end
end
