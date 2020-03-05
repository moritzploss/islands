defmodule IE.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Starts workers by calling: IE.Worker.start_link(arg)
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      IE.GameSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IE.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
