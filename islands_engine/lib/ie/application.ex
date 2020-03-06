defmodule IE.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Starts workers by calling: IE.Worker.start_link(arg)
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      IE.GameSupervisor
    ]
    :ets.new(:game_state, [:public, :named_table])
    opts = [strategy: :one_for_one, name: IE.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
