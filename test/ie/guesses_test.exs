defmodule IE.GuessesTest do
  use ExUnit.Case, async: true

  test "guesses should include hits and misses" do
    %IE.Guesses{hits: _hits, misses: _misses} = IE.Guesses.new()
  end

  test "hits should behave like sets" do
    guesses_0 = IE.Guesses.new()
    {:ok, coordinate_1} = IE.Coordinate.new(1, 1)
    {:ok, coordinate_2} = IE.Coordinate.new(2, 2)

    guesses_1 = update_in(guesses_0.hits, &MapSet.put(&1, coordinate_1))
    assert MapSet.size(guesses_1.hits) == 1

    guesses_2 = update_in(guesses_1.hits, &MapSet.put(&1, coordinate_1))
    assert MapSet.size(guesses_2.hits) == 1

    guesses_3 = update_in(guesses_2.hits, &MapSet.put(&1, coordinate_2))
    assert MapSet.size(guesses_3.hits) == 2
  end

  test "the add function should accept 'hits'" do
    guesses = IE.Guesses.new()
    {:ok, hit_coordinate1} = IE.Coordinate.new(1, 2)

    guesses_with_hit = IE.Guesses.add(guesses, :hit, hit_coordinate1)
    assert MapSet.member?(guesses_with_hit.hits, hit_coordinate1)
    assert not MapSet.member?(guesses_with_hit.misses, hit_coordinate1)
  end
end
