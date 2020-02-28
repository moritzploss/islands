defmodule IE.Board do
  def new, do: %{}

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(
      board,
      fn {key, island} ->
        key != new_key and IE.Island.overlaps?(island, new_island)
      end
    )
  end

  def position_island(board, key, %IE.Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  def all_islands_positioned?(board) do
    Enum.all?(IE.Island.types, &Map.has_key?(board, &1))
  end
end
