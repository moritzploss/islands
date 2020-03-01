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

  test "players can set islands multiple times when in players_set state" do
    rules = %Rules{
      state: :players_set,
      player1: :islands_not_set,
      player2: :islands_not_set
    }

    {:ok, player1_set} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set.state == :players_set

    {:ok, player1_set_again} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set_again.state == :players_set
  end

  test "players shouldn't be able to position islands after setting them" do
    rules = %Rules{
      state: :players_set,
      player1: :islands_not_set,
      player2: :islands_not_set
    }

    {:ok, player1_set} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set.state == :players_set

    :error = Rules.check(player1_set, {:position_island, :player1})

    {:ok, _player2_set} = Rules.check(rules, {:set_islands, :player2})
  end

  test "state should transition to player1_turn if players have set islands" do
    rules = %Rules{
      state: :players_set,
      player1: :islands_not_set,
      player2: :islands_not_set
    }

    {:ok, player1_set} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set.state == :players_set

    {:ok, player2_set} = Rules.check(player1_set, {:set_islands, :player2})
    assert player2_set.state == :player1_turn
  end
end
