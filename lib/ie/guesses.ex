defmodule IE.Guesses do
  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  def new do
    %IE.Guesses{hits: MapSet.new(), misses: MapSet.new()}
  end
end
