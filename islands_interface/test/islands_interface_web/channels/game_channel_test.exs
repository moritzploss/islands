defmodule IslandsInterfaceWeb.GameChannelTest do
  use IslandsInterfaceWeb.ChannelCase

  test "join game channel" do
    join(socket(
      "socket_id", %{}),
      IslandsInterfaceWeb.GameChannel,
      "game:test", %{}
    )
  end

  test "start new game" do
    {:ok, _, socket} = subscribe_and_join(
      socket("socket_id", %{}),
      IslandsInterfaceWeb.GameChannel,
      "game:a"
    )
    ref = push(socket, "new_game")

    assert_reply ref, :ok
  end

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

  test "add second player to game" do
    {:ok, _, socket} = subscribe_and_join(
      socket("socket_id", %{}),
      IslandsInterfaceWeb.GameChannel,
      "game:c"
    )

    push(socket, "new_game")
    push(socket, "add_player", "player 2")

    assert_broadcast "player added", %{message: _success_message}
  end

  test "only allow two players per game" do
    {:ok, _, socket} = subscribe_and_join(
      socket("socket_id", %{}),
      IslandsInterfaceWeb.GameChannel,
      "game:d"
    )

    push(socket, "new_game")
    push(socket, "add_player", "player 2")
    ref = push(socket, "add_player", "player 3")

    assert_reply ref, :error
  end
end
