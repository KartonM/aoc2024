defmodule AdventOfCode.Day12 do
  def parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, char} end)
    end)
    |> Enum.into(%{})
  end

  def get_region(grid, {x, y}, type, region \\ nil) do
    cond do
      region == nil ->
        get_region(grid, {x, y}, type, MapSet.new([{x, y}]))

      grid[{x, y}] != type ->
        {grid, region}

      true ->
        [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
        |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
        |> Enum.reduce({grid, region}, fn {new_x, new_y}, {grid, region} ->
          get_region(Map.delete(grid, {x, y}), {new_x, new_y}, type, MapSet.put(region, {x, y}))
        end)
    end
  end

  def find_regions(not_processed_grid, already_found_regions \\ [])

  def find_regions(not_processed_grid, already_found_regions) when not_processed_grid == %{},
    do: already_found_regions

  def find_regions(not_processed_grid, already_found_regions) do
    {{x, y}, type} = Enum.at(not_processed_grid, 0)
    {grid, region} = get_region(not_processed_grid, {x, y}, type)
    find_regions(grid, [{type, region} | already_found_regions])
  end

  def part1(input) do
    grid = parse_input(input)

    find_regions(grid)
    |> Enum.map(fn {type, region} ->
      perimeter =
        Enum.map(region, fn {x, y} ->
          [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
          |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
          |> Enum.filter(fn {x, y} -> grid[{x, y}] != type end)
          |> Enum.count()
        end)
        |> Enum.sum()

      area = Enum.count(region)
      perimeter * area
    end)
    |> Enum.sum()
  end

  def part2(input) do
    grid = parse_input(input)

    find_regions(grid)
    |> Enum.map(fn {type, region} ->
      sides_count =
        Enum.map(region, fn {x, y} ->
          [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
          |> Enum.count(fn {dx, dy} ->
            # Next below if considering lines on left/right; next on right if considering lines above/below
            next_garden = {x + abs(dy), y + abs(dx)}
            makes_line? = grid[{x + dx, y + dy}] != type
            next_belongs_to_region? = grid[next_garden] == type

            next_continues_line? =
              grid[
                {elem(next_garden, 0) + dx, elem(next_garden, 1) + dy}
              ] != type

            makes_line? && (!next_belongs_to_region? || !next_continues_line?)
          end)
        end)
        |> Enum.sum()

      area = Enum.count(region)
      sides_count * area
    end)
    |> Enum.sum()
  end
end
