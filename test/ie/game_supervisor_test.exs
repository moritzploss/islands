defmodule IE.GameSupervisorTest do
  use ExUnit.Case, async: true

  alias IE.GameSupervisor

  test "start and stop a supervised game process" do
    {:ok, pid} = GameSupervisor.start_game("Player 1")
    assert Process.alive?(pid)

    GameSupervisor.stop_game("Player 1")
    assert not Process.alive?(pid)
  end

  test "allow pid access by player name via Registry" do
    {:ok, pid} = GameSupervisor.start_game("Player 1")
    via = IE.Game.via_tuple("Player 1")
    assert GenServer.whereis(via) == pid

    state = :sys.get_state(via)
    assert state.player1.name == "Player 1"

    GameSupervisor.stop_game("Player 1")
  end
end
