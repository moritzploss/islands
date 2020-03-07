defmodule IslandsInterfaceWeb.GameChannel do
  use IslandsInterfaceWeb, :channel
  alias IE.{Game, GameSupervisor}

  def join("game:" <> _player, _payload, socket) do
    # {:error, %{reason: "<whatever reason you like>"}}
    {:ok, socket}
  end

end
