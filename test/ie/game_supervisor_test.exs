defmodule IE.GameSupervisorTest do
  use ExUnit.Case, async: true

  alias IE.GameSupervisor

  test "start a supervised game process" do
    {:ok, _game_pid} = GameSupervisor.start_game("Player 1")
    GameSupervisor.stop_game("Player 1")
  end
end
