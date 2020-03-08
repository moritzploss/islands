defmodule IslandsInterfaceWeb.GameChannel do
  use IslandsInterfaceWeb, :channel
  alias IE.{Game, GameSupervisor}

  def join("game:" <> _player, _payload, socket) do
    # {:error, %{reason: "<whatever reason you like>"}}
    {:ok, socket}
  end

  # def handle_in("hello", payload, socket) do
  #   push socket, "said hello", payload
  #   {:noreply, socket}
  # end

  def handle_in("hello", payload, socket) do
    broadcast! socket, "said hello", payload
    {:noreply, socket}
  end

  def handle_in("new_game", _payload, socket) do
    "game:" <> player_name = socket.topic
    reply_paylod =
      case GameSupervisor.start_game(player_name) do
        {:ok, pid} -> :ok
        {:error, reason} -> {:error, %{reason: inspect(reason)}}
      end
    {:reply, reply_paylod, socket}
  end

  defp via("game:" <> player_name) do
    Game.via_tuple(player_name)
  end

  def handle_in("add_player", player_name, socket) do
    game_pid = via(socket.topic)
    case Game.add_player(game_pid, player_name) do
      :ok ->
        broadcast! socket, "player added", %{
          message: "New player just joined: " <> player_name
        }
        {:noreply, socket}
      :error -> {:reply, :error, socket}
    end
  end
end
