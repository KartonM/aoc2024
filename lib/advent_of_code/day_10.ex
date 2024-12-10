defmodule AdventOfCode.Day10 do
  def parse_input(input) do
    String.split(input, "\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} -> {{x, y}, String.to_integer(char)} end)
    end)
    |> Enum.into(%{})
  end

  def find_trails_starting_from(grid, {x, y}, desired_height \\ 0, trail \\ []) do
    cond do
      grid[{x, y}] != desired_height ->
        []

      trail == [] ->
        find_trails_starting_from(grid, {x, y}, desired_height, [{x, y}])

      desired_height == 9 && grid[{x, y}] == 9 ->
        [trail]

      true ->
        [{0, -1}, {1, 0}, {0, 1}, {-1, 0}]
        |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
        |> Enum.flat_map(fn {x, y} ->
          find_trails_starting_from(grid, {x, y}, desired_height + 1, [{x, y}] ++ trail)
        end)
    end
  end

  def part1(input) do
    grid = parse_input(input)

    grid
    |> Enum.map(fn {pos, _} -> find_trails_starting_from(grid, pos) |> Enum.map(&hd/1) |> Enum.uniq() |> Enum.count()  end)
    |> Enum.sum()
  end

  def part2(input) do
    grid = parse_input(input)

    grid
    |> Enum.map(fn {pos, _} -> find_trails_starting_from(grid, pos) |> Enum.count()  end)
    |> Enum.sum()
  end
end
