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
end
