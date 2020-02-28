defmodule IE.IslandsTest do
  use ExUnit.Case, async: true

  test "create valid island" do
    {:ok, coordinate} = IE.Coordinate.new(4, 6)
    {:ok, _} = IE.Island.new(:l_shape, coordinate)
  end

  test "do not create island for invalid type" do
    {:ok, coordinate} = IE.Coordinate.new(4, 6)
    {:error, _} = IE.Island.new(:invalid_type, coordinate)
  end

  test "do not create island if island would be outside of board" do
    {:ok, coordinate} = IE.Coordinate.new(10, 10)
    {:error, _} = IE.Island.new(:l_shape, coordinate)
  end

  test "identify overlapping islands" do
    {:ok, coordinate1} = IE.Coordinate.new(4, 6)
    {:ok, island1} = IE.Island.new(:l_shape, coordinate1)

    {:ok, coordinate2} = IE.Coordinate.new(4, 6)
    {:ok, island2} = IE.Island.new(:dot, coordinate2)

    {:ok, coordinate3} = IE.Coordinate.new(1, 1)
    {:ok, island3} = IE.Island.new(:dot, coordinate3)

    assert IE.Island.overlaps?(island1, island2)
    assert not IE.Island.overlaps?(island1, island3)
  end

  test "identify hits" do
    {:ok, coordinate} = IE.Coordinate.new(4, 6)
    {:ok, island} = IE.Island.new(:l_shape, coordinate)

    {:hit, _} = IE.Island.guess(island, coordinate)
  end

  test "identify misses" do
    {:ok, coordinate1} = IE.Coordinate.new(4, 6)
    {:ok, island} = IE.Island.new(:l_shape, coordinate1)
    {:ok, coordinate2} = IE.Coordinate.new(1, 1)

    :miss = IE.Island.guess(island, coordinate2)
  end

  test "determine that island is forested" do
    {:ok, upper_left} = IE.Coordinate.new(1, 2)
    {:ok, island} = IE.Island.new(:s_shape, upper_left)
    forrested_island = Enum.reduce(
      island.coordinates,
      island,
      fn (coordinate, acc) ->
        {:hit, new_acc} = IE.Island.guess(acc, coordinate)
        new_acc
      end
    )

    assert IE.Island.forested?(forrested_island)
  end

  test "determine that island is not forrested" do
    {:ok, upper_left} = IE.Coordinate.new(1, 2)
    {:ok, island} = IE.Island.new(:atoll, upper_left)
    {:hit, unforrested_island} = IE.Island.guess(island, upper_left)

    assert not IE.Island.forested?(unforrested_island)
  end
end
