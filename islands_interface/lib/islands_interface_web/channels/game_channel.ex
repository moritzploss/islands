defmodule IslandsInterfaceWeb.GameChannel do
  use IslandsInterfaceWeb, :channel
  alias IE.{Game, GameSupervisor}

  def join("game:" <> _player, _payload, socket) do
    # {:error, %{reason: "<whatever reason you like>"}}
    {:ok, socket}
  end

  defp via("game:" <> player_name) do
    Game.via_tuple(player_name)
  end

  def handle_in("new_game", _payload, socket) do
    "game:" <> player_name = socket.topic
    reply_paylod =
      case GameSupervisor.start_game(player_name) do
        {:ok, _pid} -> :ok
        {:error, reason} -> {:error, %{reason: inspect(reason)}}
      end
    {:reply, reply_paylod, socket}
  end

  def handle_in("add_player", player_name, socket) when is_binary(player_name) do
    game_pid = via(socket.topic)
    case Game.add_player2(game_pid, player_name) do
      :ok ->
        broadcast! socket, "player added", %{
          message: "New player just joined: " <> player_name
        }
        {:noreply, socket}
      :error -> {:reply, :error, socket}
    end
  end

  def handle_in("position_island",  %{"col" => col, "player" => player, "row" => row, "type" => type}, socket) do
    player = String.to_existing_atom(player)
    type = String.to_existing_atom(type)

    case Game.position_island(via(socket.topic), player, type, row, col) do
      :ok -> {:reply, :ok, socket}
      _ -> {:reply, :error, socket}
    end
  end

  def handle_in("set_islands", %{"player" => player}, socket) do
    player_as_atom = String.to_existing_atom(player)

    reply_payload =
      case Game.set_island(via(socket.topic), player_as_atom) do
        {:ok, board} ->
          broadcast!(socket, "player_set_islands", %{player: player})
          {:ok, %{board: board}}
        {:error, reason} -> {:error, %{reason: inspect(reason)}}
      end
    {:reply, reply_payload, socket}
  end

  def handle_in("guess_coordinate", %{"player" => player, "row" => row, "col" => col}, socket) do
    player_as_atom = String.to_existing_atom(player)

    case Game.guess_coordinate(via(socket.topic), player_as_atom, row, col) do
      {hit_or_miss, island, win} ->
        result = %{hit: hit_or_miss === :hit, island: island, win: win}
        broadcast!(
          socket,
          "player_guessed_coordinate",
          %{player: player, row: row, col: col, result: result}
        )
        {:noreply, socket}
      :error ->
        {:reply, {:error, %{player: player, reason: "Not your turn"}}, socket}
      {:error, reason} ->
        {:reply, {:error, %{player: player, reason: inspect(reason)}}, socket}
    end
  end

  def handle_in(_event, _payload, socket) do
    {:reply, :error, socket}
  end
end
