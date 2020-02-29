defmodule IE.BoardTestHelper do
  def result_if_ok(func) do
    fn {arg1, arg2} ->
      {:ok, result} = func.(arg2, arg1)
      result
    end
  end
end

defmodule IE.BoardTest do
  use ExUnit.Case, async: true
  import IE.BoardTestHelper
  alias IE.Board

  setup do
    {:ok, coordinate} = IE.Coordinate.new(2, 2)
    {:ok, island} = IE.Island.new(:square, coordinate)
    %{island: island, key: :square, board: Board.new()}
  end

  test "accept position if space not occupied", default do
    board = Board.position_island(default.board, default.key, default.island)
    assert is_map(board)
  end

  test "reject position if space is occupied", default do
    board = Board.position_island(default.board, default.key, default.island)
    {:ok, coordinate} = IE.Coordinate.new(2, 2)
    {:ok, island} = IE.Island.new(:dot, coordinate)

    {:error, :overlapping_island} = Board.position_island(board, :dot, island)
  end

  test "not all islands positioned", default do
    board = Board.position_island(default.board, default.key, default.island)
    assert not Board.all_islands_positioned?(board)
  end

  test "all islands positioned" do
    islands = [{1, 1}, {3, 1}, {4, 1}, {1, 4}, {4, 4}]
      |> Enum.map(result_if_ok(&IE.Coordinate.new/2))
      |> Enum.zip(IE.Island.types)
      |> Enum.map(result_if_ok(&IE.Island.new/2))
      |> Enum.zip(IE.Island.types)

    board = Enum.reduce(islands, Board.new(),
      fn ({island, type}, board) ->
        Board.position_island(board, type, island)
      end
    )

    assert Board.all_islands_positioned?(board)
  end

  test "correctly categorize guess that results in miss", default do
    board_with_square = Board.position_island(
      default.board, :square, default.island
    )
    {:ok, guess_coordinate} = IE.Coordinate.new(10, 10)

    {:miss, :none, :no_win, _} = Board.guess(
      board_with_square, guess_coordinate
    )
  end

  test "correctly categorize guess that results in hit", default do
    board_with_square = Board.position_island(
      default.board, :square, default.island
    )
    {:ok, guess_coordinate} = IE.Coordinate.new(2, 2)

    {:hit, :none, :no_win, _} = Board.guess(
      board_with_square, guess_coordinate
    )
  end

  test "detect forrested island", default do
    board_with_square = Board.position_island(
      default.board, :square, default.island
    )
    coordinates = for position <- [{2, 2}, {2, 3}, {3, 2}, {3, 3}] do
      result_if_ok(&IE.Coordinate.new/2).(position)
    end

    {:win, _ } = Enum.reduce(coordinates, board_with_square,
      fn (coordinate, board) ->
        case Board.guess(board, coordinate) do
          {:hit, :none, :no_win, board} -> board
          {:hit, :square, :win, board} -> {:win, board}
        end
      end
    )
  end
end
