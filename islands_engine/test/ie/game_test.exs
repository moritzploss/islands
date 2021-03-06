defmodule IE.GameTest do
  use ExUnit.Case, async: false
  alias IE.Game

  setup do
    :ets.delete_all_objects(:game_state)
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")
    %{pid: game_pid}
  end

  test "setup new game by starting GenServer with name of player1", game do
    state = :sys.get_state(game.pid)

    assert state.player1.name == "Player 1"
    assert Map.has_key?(state, :player1)
    assert Map.has_key?(state, :player2)
    assert Map.has_key?(state, :rules)
  end

  test "add player2 to game" do
    {:ok, game_pid} = Game.start_link("First Player")
    :ok = Game.add_player2(game_pid, "Second Player")
    state = :sys.get_state(game_pid)

    assert state.player2.name == "Second Player"
  end

  test "allow players to position islands", game do
    state = :sys.get_state(game.pid)

    assert state.rules.state == :players_set
    :ok = Game.position_island(game.pid, :player1, :square, 1, 1)
    :ok = Game.position_island(game.pid, :player2, :square, 1, 1)
  end

  test "handle unallowed actions error" do
    {:ok, game_pid} = Game.start_link("First Player")
    :error = Game.position_island(game_pid, :player1, :dot, 1, 1)
  end

  test "handle invalid coordinates error", game do
    {:error, :invalid_coordinate} = Game.position_island(
      game.pid, :player1, :square, 1, 10
    )
  end

  test "handle invalid island type error", game do
    {:error, :invalid_island_type} = Game.position_island(
      game.pid, :player1, :invalid_type, 1, 1
    )
  end

  test "handle overlapping islands error", game do
    :ok = Game.position_island(game.pid, :player1, :dot, 1, 1)
    {:error, :overlapping_island} = Game.position_island(
      game.pid, :player1, :square, 1, 1
    )
  end

  test "do not allow to set islands when not all islands are positioned", game do
    {:error, :not_all_islands_positioned} = Game.set_island(game.pid, :player1)
  end

  test "allow to set islands when all islands are positioned", game do
    coordinates = [{1, 1}, {7, 1}, {4, 1}, {1, 4}, {4, 4}]

    position_island = fn ({{row, col}, type}) ->
      Game.position_island(game.pid, :player1, type, row, col)
    end

    status_codes = coordinates
      |> Enum.zip(IE.Island.types)
      |> Enum.map(position_island)

    Enum.map(status_codes, fn (status_code) -> assert status_code == :ok end)

    {:ok, board} = Game.set_island(game.pid, :player1)
    state = :sys.get_state(game.pid)

    assert state.rules.state == :players_set
    assert state.rules.player1 == :islands_set
    assert state.player1.board == board
  end

  test "transition to player1_turn once all islands are set", game do
    :error = Game.guess_coordinate(game.pid, :player1, 1, 1)

    coordinates = [{1, 1}, {7, 1}, {4, 1}, {1, 4}, {4, 4}]

    position_island = fn ({{row, col}, type}, player) ->
      Game.position_island(game.pid, player, type, row, col)
    end

    coordinates
      |> Enum.zip(IE.Island.types)
      |> Enum.map(&position_island.(&1, :player1))

    coordinates
      |> Enum.zip(IE.Island.types)
      |> Enum.map(&position_island.(&1, :player2))

    {:ok, _board} = Game.set_island(game.pid, :player1)
    {:ok, _board} = Game.set_island(game.pid, :player2)
    state = :sys.get_state(game.pid)

    assert state.rules.state == :player1_turn
  end

  test "don't allow guessing when in initialized state" do
    {:ok, game_pid} = Game.start_link("First Player")
    :error = Game.guess_coordinate(game_pid, :player1, 1, 1)
  end

  test "don't allow guessing when in player_set state", game do
    :error = Game.guess_coordinate(game.pid, :player1, 1, 1)
  end

  test "allow guessing when in player1_turn state", game do
    Game.position_island(game.pid, :player1, :dot, 1, 2)
    Game.position_island(game.pid, :player2, :square, 3, 4)

    :sys.replace_state(game.pid, fn current_state ->
      %{current_state | rules: %IE.Rules{state: :player1_turn}}
    end)

    {:miss, :none, :no_win} = Game.guess_coordinate(game.pid, :player1, 7, 8)
    {:miss, :none, :no_win} = Game.guess_coordinate(game.pid, :player2, 6, 5)
    {:hit, :none, :no_win} = Game.guess_coordinate(game.pid, :player1, 3, 4)
    {:hit, :dot, :win} = Game.guess_coordinate(game.pid, :player2, 1, 2)
  end

  test "enfore unique process names" do
    {:ok, _pid} = Game.start_link("First Player")
    {:error, {:already_started, _pid}} = Game.start_link("First Player")
  end

  test "write freshly initialized state to game_state table", default do
    [{_key, state}] = :ets.lookup(:game_state, "Player 1")
    assert :sys.get_state(default.pid) == state
  end
end
