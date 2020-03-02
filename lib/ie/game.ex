defmodule IE.Game do
  use GenServer

  alias IE.Board
  alias IE.Coordinate
  alias IE.Guesses
  alias IE.Island
  alias IE.Rules

  @players [:player1, :player2]

  # Public interface

  @spec start_link(binary) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(player_name) when is_binary(player_name) do
    GenServer.start_link(__MODULE__, player_name, [])
  end

  def add_player2(game, name) when is_binary(name) do
   GenServer.call(game, {:add_player, name})
  end

  def position_island(game, player, island_type, row, col) when player in @players do
    GenServer.call(game, {:position_island, player, island_type, row, col})
  end

  def set_island(game, player) when player in @players do
    GenServer.call(game, {:set_islands, player})
  end

  # GenServer Helper

  defp update_player2_name(state, name) do
    put_in(state.player2.name, name)
  end

  defp update_rules(state, rules) do
    %{state | rules: rules}
  end

  defp update_board(state, player, board) do
    Map.update!(state, player, fn player -> %{player | board: board} end)
  end

  defp reply_with_state(state, reply) do
    {:reply, reply, state}
  end

  defp get_player_board(state, player) do
    Map.get(state, player).board
  end

  # GenServer Callbacks

  def init(player_name) do
    player1 = %{name: player_name, board: Board.new(), guesses: Guesses.new()}
    player2 = %{name: nil, board: Board.new(), guesses: Guesses.new()}
    {:ok, %{player1: player1, player2: player2, rules: %Rules{}}}
  end

  def handle_call({:add_player, name}, _from, state) do
    case Rules.check(state.rules, :add_player) do
      :error -> {:reply, :error, state}
      {:ok, rules} -> state
                      |> update_player2_name(name)
                      |> update_rules(rules)
                      |> reply_with_state(:ok)
    end
  end

  def handle_call({:position_island, player, island_type, row, col}, _from, state) do
    player_board = get_player_board(state, player)
    with {:ok, rules} <- Rules.check(state.rules, {:position_island, player}),
      {:ok, upper_left} <- Coordinate.new(row, col),
      {:ok, island} <- Island.new(island_type, upper_left),
      %{} = board <- Board.position_island(player_board, island_type, island)
    do
      state
      |> update_board(player, board)
      |> update_rules(rules)
      |> reply_with_state(:ok)
    else
      :error -> {:reply, :error, state}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  def handle_call({:set_islands, player}, _from, state) do
    player_board = get_player_board(state, player)
    with {:ok, rules} <- Rules.check(state.rules, {:set_islands, player}),
      true <- Board.all_islands_positioned?(player_board)
    do
      state
      |> update_rules(rules)
      |> reply_with_state({:ok, player_board})
    else
      :error -> {:reply, :error, state}
      false -> {:reply, {:error, :not_all_islands_positioned}, state}
    end
  end
end
