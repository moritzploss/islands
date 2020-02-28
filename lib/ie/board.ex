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

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case IE.Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp forested?(board, key) do
    board
      |> Map.fetch!(key)
      |> IE.Island.forested?()
  end

  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  defp all_forested?(board) do
    Enum.all?(board, fn {_key, island} -> IE.Island.forested?(island) end)
  end

  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  defp guess_response(:miss, board) do
    {:miss, :none, :no_win, board}
  end

  def guess(board, %IE.Coordinate{} = coordinate) do
    board
      |> check_all_islands(coordinate)
      |> guess_response(board)
  end
end
