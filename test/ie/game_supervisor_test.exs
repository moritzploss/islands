defmodule IE.GameSupervisorTest do
  use ExUnit.Case, async: true

  alias IE.GameSupervisor

  test "start and stop a supervised game process" do
    {:ok, pid} = GameSupervisor.start_game("Player 1")
    assert Process.alive?(pid)
    GameSupervisor.stop_game("Player 1")
    assert not Process.alive?(pid)
  end
end
