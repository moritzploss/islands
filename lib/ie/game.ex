defmodule IE.Game do
  use GenServer
  alias IE.{Board, Guesses, Rules}

  # Client

  def start_link(player_name) when is_binary(player_name) do
    GenServer.start_link(__MODULE__, player_name, [])
  end

  def add_player2(game, name) when is_binary(name) do
   GenServer.call(game, {:add_player, name})
  end

  # GenServer Callbacks

  def init(player_name) do
    player1 = %{name: player_name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  defp update_player2_name(state, name) do
    put_in(state.player2.name, name)
  end

  defp update_rules(state, rules) do
    %{state | rules: rules}
  end

  defp reply_success(state, reply) do
    {:reply, reply, state}
  end

  def handle_call({:add_player, name}, _from, state) do
    case Rules.check(state.rules, :add_player) do
      :error -> {:reply, :error, state}
      {:ok, rules} -> state
                      |> update_player2_name(name)
                      |> update_rules(rules)
                      |> reply_success(:ok)
    end
  end

  # def handle_cast(msg, state) do

  # end
end
