defmodule IE.Rules do
  alias IE.Rules
  defstruct [
    state: :initialized,
    player1: :islands_not_set,
    player2: :islands_not_set
  ]

  def new, do: %Rules{}

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:position_island, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end

  def check(_state, _action) do
    :error
  end

end
