defmodule IslandsInterfaceWeb.GameChannelTest do
  use IslandsInterfaceWeb.ChannelCase

  test "only start one game per player" do
    {:ok, _, socket} = subscribe_and_join(
      socket("socket_id", %{}),
      IslandsInterfaceWeb.GameChannel,
      "game:b"
    )

    push(socket, "new_game")
    ref = push(socket, "new_game")

    assert_reply ref, :error
  end

  test "add second player to game", %{start_game: start_game} do
    {:ok, _socket} = start_game.()
    assert_broadcast "player added", %{message: _success_message}
  end

  test "only allow two players per game", %{start_game: start_game} do
    {:ok, socket} = start_game.()
    ref = push(socket, "add_player", "player 3")
    assert_reply ref, :error
  end

  test "position island", %{start_game: start_game} do
    {:ok, socket} = start_game.()

    ref = push(socket, "position_island", %{
      player: "player1",
      type: "dot",
      row: 1,
      col: 2
    })
    assert_reply ref, :ok
  end

  test "refuse positioning with invalid payload", %{start_game: start_game} do
    {:ok, socket} = start_game.()
    ref = push(socket, "position_island", %{
      foo: "player1",
      type: "dot",
      row: 1,
      col: 2
    })
    assert_reply ref, :error
  end

  test "player can set islands after positioning", %{start_game: start_game} do
    {:ok, socket} = start_game.()

    position_island = fn ({{row, col}, type}, player) ->
      push(socket, "position_island", %{
        player: Atom.to_string(player),
        type: Atom.to_string(type),
        row: row,
        col: col
      })
    end

    [{1, 1}, {7, 1}, {4, 1}, {1, 4}, {4, 4}]
      |> Enum.zip(IE.Island.types)
      |> Enum.map(&position_island.(&1, :player1))

    ref = push(socket, "set_islands", %{player: "player1"})
    assert_reply ref, :ok

    ref2 = push(socket, "set_islands", %{player: "player2"})
    assert_reply ref2, :error
  end

  test "players can guess island coordinates", %{start_game: start_game} do
    {:ok, socket} = start_game.()

    position_island = fn ({{row, col}, type}, player) ->
      push(socket, "position_island", %{
        player: Atom.to_string(player),
        type: Atom.to_string(type),
        row: row,
        col: col
      })
    end

    coordinates = [{1, 1}, {7, 1}, {4, 1}, {1, 4}, {4, 4}]

    coordinates
      |> Enum.zip(IE.Island.types)
      |> Enum.map(&position_island.(&1, :player1))

    coordinates
      |> Enum.zip(IE.Island.types)
      |> Enum.map(&position_island.(&1, :player2))

    push(socket, "set_islands", %{player: "player1"})
    push(socket, "set_islands", %{player: "player2"})

    push(socket, "guess_coordinate", %{player: "player1", row: 1, col: 1})
    assert_broadcast(
      "player_guessed_coordinate",
      %{result: %{hit: true, island: :none, win: :no_win}}
    )

    ref = push(socket, "guess_coordinate", %{player: "player1", row: 1, col: 2})
    assert_reply(ref, :error)

    push(socket, "guess_coordinate", %{player: "player2", row: 7, col: 1})
    assert_broadcast(
      "player_guessed_coordinate",
      %{result: %{hit: true, island: :dot, win: :no_win}}
    )
  end
end
