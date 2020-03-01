defmodule IE.Game do
  use GenServer
  alias IE.{Board, Guesses, Rules}

  def start_link(player_name) when is_binary(player_name) do
    GenServer.start_link(__MODULE__, player_name, [])
  end

  def init(player_name) do
    player1 = %{name: player_name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  # def handle_call(msg, from, state) do

  # end

  # def handle_cast(msg, state) do

  # end
end
