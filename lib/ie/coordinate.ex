defmodule IE.Coordinate do
  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @board_range 1..10

  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %IE.Coordinate{row: row, col: col}}
  end

  def new(_row, _col) do
    {:error, :invalid_coordinate}
  end

end
