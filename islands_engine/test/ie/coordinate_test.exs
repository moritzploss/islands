defmodule IE.CoordinateTest do
  use ExUnit.Case, async: true

  alias IE.Coordinate

  test "new coordinates should have row and col" do
    {:ok, %Coordinate{row: row, col: col}} = Coordinate.new(1, 2)
    assert row == 1
    assert col == 2
  end

  test "row and col values must be in range 1.10" do
    {:ok, _} = Coordinate.new(1, 10)
    {:error, _} = Coordinate.new(-1, 1)
    {:error, _} = Coordinate.new(1, -1)
    {:error, _} = Coordinate.new(10, 11)
    {:error, _} = Coordinate.new(11, 10)
  end
end
