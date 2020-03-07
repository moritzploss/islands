defmodule IE.GameSupervisor do
  use DynamicSupervisor

  alias IE.Game

  def start_link(_options) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
    # Supervisor.init([Game], strategy: :simple_one_for_one)
  end

  defp pid_from_name(player_name) do
    player_name
    |> Game.via_tuple()
    |> GenServer.whereis
  end

  def start_game(player_name) do
    spec = %{
      id: Game,
      start: {Game, :start_link, [player_name]},
      restart: :transient
    }
    # spec = {IE.Game, player_name: player_name}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_game(player_name) do
    :ets.delete(:game_state, player_name)
    DynamicSupervisor.terminate_child(__MODULE__, pid_from_name(player_name))
  end
end
