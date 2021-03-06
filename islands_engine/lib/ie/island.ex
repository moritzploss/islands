defmodule IE.Island do
  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct @enforce_keys

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]

  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]

  defp offsets(:dot), do: [{0, 0}]

  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]

  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]

  defp offsets(_type), do: {:error, :invalid_island_type}

  def new(type, %IE.Coordinate{} = upper_left) do
    with [_|_] = offsets <- offsets(type),
      %MapSet{} = coordinates <- add_coordinates(offsets, upper_left)
    do
      {:ok, %IE.Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  defp add_coordinate(coordinates, %IE.Coordinate{row: row, col: col},
    {row_offset, col_offset}) do
      case IE.Coordinate.new(row + row_offset, col + col_offset) do
        {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
        error -> {:halt, error}
      end
  end

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(
      offsets,
      MapSet.new(),
      fn offset, acc -> add_coordinate(acc, upper_left, offset) end
    )
  end

  def overlaps?(existing_island, new_island) do
    not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)
  end

  def guess(%IE.Island{} = island, %IE.Coordinate{} = coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}
      false -> :miss
    end
  end

  def forested?(%IE.Island{} = island) do
    MapSet.equal?(island.coordinates, island.hit_coordinates)
  end

  def types, do: [:atoll, :dot, :l_shape, :s_shape, :square]

  def serialize(%IE.Island{} = island) do
    island_map = Map.from_struct(island)

    serialize_coordinates = fn key, acc ->
      Map.put(acc, key,
        Map.fetch!(island_map, key)
        |> MapSet.to_list
        |> Enum.map(&IE.Coordinate.serialize(&1))
      )
    end

    island_map
    |> Map.keys()
    |> Enum.reduce(Map.new(), serialize_coordinates)
  end
end
