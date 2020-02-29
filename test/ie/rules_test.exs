defmodule IE.RulesTest do
  use ExUnit.Case, async: true
  alias IE.Rules

  test "allow transition from 'initialized' to 'players_set'" do
    rules = Rules.new()
    {:ok, %Rules{state: :players_set}} = Rules.check(rules, :add_player)
  end

  test "don't allow random transition from 'initialized'" do
    rules = Rules.new()
    :error = Rules.check(rules, :random_action)
  end

  test "allow players to set their islands if not set yet" do
    {:ok, rules} = Rules.check(Rules.new(), :add_player)
    {:ok, _new_rules} = Rules.check(rules, {:position_island, :player1})
    # :error = Rules.check(new_rules, {:position_island, :player1})
  end
end
