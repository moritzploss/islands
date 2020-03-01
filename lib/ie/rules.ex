defmodule IE.Rules do
  alias IE.Rules
  defstruct [
    state: :initialized,
    player1: :islands_not_set,
    player2: :islands_not_set
  ]

  def new, do: %Rules{}

  defp both_players_islands_set?(rules) do
    rules.player1 == :islands_set && rules.player2 == :islands_set
  end

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_island, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    new_rules = Map.put(rules, player, :islands_set)
    case both_players_islands_set?(new_rules) do
      true -> {:ok, %Rules{new_rules | state: :player1_turn}}
      false -> {:ok, new_rules}
    end
  end

  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %Rules{rules | state: :player2_turn}}
  end

  def check(%Rules{state: :player1_turn} = rules, {:win_check, win_or_not}) do
    case win_or_not do
      :no_win -> {:ok, rules}
      :win -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(_state, _action) do
    :error
  end

end
