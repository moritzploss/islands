defmodule IE.GameTest do
  use ExUnit.Case, async: true
  alias IE.Game

  test "setup new game by starting GenServer with name of player1" do
    {:ok, game_pid} = Game.start_link("Player 1")
    state = :sys.get_state(game_pid)

    assert state.player1.name == "Player 1"
    assert Map.has_key?(state, :player1)
    assert Map.has_key?(state, :player2)
    assert Map.has_key?(state, :rules)
  end

  test "add player2 to game" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")
    state = :sys.get_state(game_pid)

    assert state.player2.name == "Player 2"
  end

  test "allow players to position islands" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")
    state = :sys.get_state(game_pid)

    assert state.rules.state == :players_set
    :ok = Game.position_island(game_pid, :player1, :square, 1, 1)
    :ok = Game.position_island(game_pid, :player2, :square, 1, 1)
  end

  test "handle unallowed actions error" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :error = Game.position_island(game_pid, :player1, :dot, 1, 1)
  end

  test "handle invalid coordinates error" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")

    {:error, :invalid_coordinate} = Game.position_island(
      game_pid, :player1, :square, 1, 10
    )
  end

  test "handle invalid island type error" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")

    {:error, :invalid_island_type} = Game.position_island(
      game_pid, :player1, :invalid_type, 1, 1
    )
  end

  test "handle overlapping islands error" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")

    :ok = Game.position_island(game_pid, :player1, :dot, 1, 1)
    {:error, :overlapping_island} = Game.position_island(
      game_pid, :player1, :square, 1, 1
    )
  end

  test "do not allow to set islands when not all islands are positioned" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")

    {:error, :not_all_islands_positioned} = Game.set_island(game_pid, :player1)
  end

  test "allow to set islands when all islands are positioned" do
    {:ok, game_pid} = Game.start_link("Player 1")
    :ok = Game.add_player2(game_pid, "Player 2")

    position_island = fn ({{row, col}, type}) ->
      Game.position_island(game_pid, :player1, type, row, col)
    end

    coordinates = [{1, 1}, {7, 1}, {4, 1}, {1, 4}, {4, 4}]

    status_codes = coordinates
      |> Enum.zip(IE.Island.types)
      |> Enum.map(position_island)

    {:ok, board} = Game.set_island(game_pid, :player1)
    state = :sys.get_state(game_pid)

    Enum.map(status_codes, fn (status_code) -> assert status_code == :ok end)
    assert state.rules.state == :players_set
    assert state.rules.player1 == :islands_set
    assert state.player1.board == board
  end
end
