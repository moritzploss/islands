defmodule IE.Guesses do
  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  def new do
    %IE.Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end

  def add(%IE.Guesses{} = guesses, :hit, %IE.Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%IE.Guesses{} = guesses, :miss, %IE.Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end
