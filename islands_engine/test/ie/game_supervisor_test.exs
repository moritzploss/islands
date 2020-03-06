defmodule IE.GameSupervisorTest do
  use ExUnit.Case, async: false

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

    :ok = GameSupervisor.stop_game("Player 1")
  end

  test "ensure that game state is cleaned up after game ends" do
    {:ok, _pid} = GameSupervisor.start_game("Player 1")
    via = IE.Game.via_tuple("Player 1")
    pid = GenServer.whereis(via)

    :ok = GameSupervisor.stop_game("Player 1")

    assert not Process.alive?(pid)
    assert GenServer.whereis(via) == nil
    assert :ets.lookup(:game_state, "Player 1") == []
  end
end
