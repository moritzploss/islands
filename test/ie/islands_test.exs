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

  test "correctly identify overlapping islands" do
    {:ok, coordinate1} = IE.Coordinate.new(4, 6)
    {:ok, island1} = IE.Island.new(:l_shape, coordinate1)

    {:ok, coordinate2} = IE.Coordinate.new(4, 6)
    {:ok, island2} = IE.Island.new(:dot, coordinate2)

    {:ok, coordinate3} = IE.Coordinate.new(1, 1)
    {:ok, island3} = IE.Island.new(:dot, coordinate3)

    assert IE.Island.overlaps?(island1, island2)
    assert not IE.Island.overlaps?(island1, island3)
  end

  test "correctly identify hits" do
    {:ok, coordinate} = IE.Coordinate.new(4, 6)
    {:ok, island} = IE.Island.new(:l_shape, coordinate)

    {:hit, _} = IE.Island.guess(island, coordinate)
  end

  test "correctly identify misses" do
    {:ok, coordinate1} = IE.Coordinate.new(4, 6)
    {:ok, island} = IE.Island.new(:l_shape, coordinate1)
    {:ok, coordinate2} = IE.Coordinate.new(1, 1)

    :miss = IE.Island.guess(island, coordinate2)
  end
end
