defmodule AdventOfCode.Day06 do
  def parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn {char, j} -> {{j, i}, char} end)
    end)
    |> Enum.into(%{})
  end

  def get_starting_position(grid) do
    Enum.find(grid, fn {{_, _}, char} -> char == "^" end) |> elem(0)
  end

  def get_next_position({x, y}, dir_i) do
    directions = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
    {dx, dy} = elem(directions, dir_i)
    {x + dx, y + dy}
  end

  def get_visited_squares(grid, {x, y}, dir_i, visited \\ MapSet.new()) do
    next_pos = get_next_position({x, y}, dir_i)

    case {grid[next_pos], {x, y, dir_i} in visited} do
      {_, true} ->
        :loop

      {"#", _} ->
        get_visited_squares(grid, {x, y}, rem(dir_i + 1, 4), visited)

      {nil, _} ->
        visited

      _ ->
        get_visited_squares(grid, next_pos, dir_i, MapSet.put(visited, {x, y, dir_i}))
    end
  end

  def part1(input) do
    grid = parse_input(input)
    starting_position = get_starting_position(grid)

    visited =
      get_visited_squares(grid, starting_position, 0)

    MapSet.size(visited)
  end

  def part2(input) do
    grid = parse_input(input)
    starting_position = get_starting_position(grid)

    get_visited_squares(grid, starting_position, 0)
    |> MapSet.to_list()
    |> Enum.map(fn {x, y, dir_i} ->
      next_position = get_next_position({x, y}, dir_i)

      res = !Enum.member?(["^", "#", nil], grid[next_position]) &&
        get_visited_squares(Map.put(grid, next_position, "#"), starting_position, 0) == :loop
      if res, do: next_position, else: nil
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.count()
  end
end
