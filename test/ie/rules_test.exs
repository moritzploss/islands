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

  test "players can set islands multiple times when in players_set state" do
    rules = %Rules{Rules.new() | state: :players_set}

    {:ok, player1_set} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set.state == :players_set

    {:ok, player1_set_again} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set_again.state == :players_set
  end

  test "players shouldn't be able to position islands after setting them" do
    rules = %Rules{Rules.new() | state: :players_set}

    {:ok, player1_set} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set.state == :players_set

    :error = Rules.check(player1_set, {:position_island, :player1})

    {:ok, _player2_set} = Rules.check(rules, {:set_islands, :player2})
  end

  test "state should transition to player1_turn if players have set islands" do
    rules = %Rules{Rules.new() | state: :players_set}

    {:ok, player1_set} = Rules.check(rules, {:set_islands, :player1})
    assert player1_set.state == :players_set

    {:ok, player2_set} = Rules.check(player1_set, {:set_islands, :player2})
    assert player2_set.state == :player1_turn
  end

  test "once in player1_turn state, disallow transitions to previous states" do
    rules = %Rules{Rules.new() | state: :player1_turn}

    :error = Rules.check(rules, :add_player)
    :error = Rules.check(rules, {:position_islands, :player2})
    :error = Rules.check(rules, {:position_islands, :player1})
    :error = Rules.check(rules, {:set_islands, :player1})
    :error = Rules.check(rules, {:set_islands, :player2})
  end

  test "after guess of player1, transition to player2_turn" do
    rules = %Rules{Rules.new() | state: :player1_turn}
    {:ok, player2_turn} = Rules.check(rules, {:guess_coordinate, :player1})
    assert player2_turn.state == :player2_turn
  end

  test "after positive win_check for player1, transition to game_over" do
    rules = %Rules{Rules.new() | state: :player1_turn}
    {:ok, game_over} = Rules.check(rules, {:win_check, :win})
    assert game_over.state == :game_over
  end

  test "after negative win_check for player1, stay in player1_turn" do
    rules = %Rules{Rules.new() | state: :player1_turn}
    {:ok, player1_turn} = Rules.check(rules, {:win_check, :no_win})
    assert player1_turn.state == :player1_turn
  end

  test "don't allow guess by player2 when in it's player1's turn" do
    rules = %Rules{Rules.new() | state: :player1_turn}
    :error = Rules.check(rules, {:guess_coordinate, :player2})
  end

  test "after guess of player2, transition to player1_turn" do
    rules = %Rules{Rules.new() | state: :player2_turn}
    {:ok, player1_turn} = Rules.check(rules, {:guess_coordinate, :player2})
    assert player1_turn.state == :player1_turn
  end

  test "after positive win_check for player2, transition to game_over" do
    rules = %Rules{Rules.new() | state: :player2_turn}
    {:ok, game_over} = Rules.check(rules, {:win_check, :win})
    assert game_over.state == :game_over
  end

  test "after negative win_check for player2, stay in player2_turn" do
    rules = %Rules{Rules.new() | state: :player2_turn}
    {:ok, player1_turn} = Rules.check(rules, {:win_check, :no_win})
    assert player1_turn.state == :player2_turn
  end
end
