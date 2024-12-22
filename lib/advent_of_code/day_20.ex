defmodule AdventOfCode.Day20 do
  def parse_input(input) do
    grid =
      String.split(input, "\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Enum.into(%{})

    starting_position = Enum.find(grid, fn {_, char} -> char == "S" end) |> elem(0)
    target_position = Enum.find(grid, fn {_, char} -> char == "E" end) |> elem(0)

    {grid |> Map.put(starting_position, ".") |> Map.put(target_position, "."), starting_position,
     target_position}
  end

  def distances(grid, {x, y}, target, distances, prev \\ nil) do
    distances =
      if prev == nil,
        do: Map.put(distances, {x, y}, 0),
        else: Map.put(distances, {x, y}, distances[prev] + 1)

    next =
      [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
      |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
      |> Enum.find(fn new_position ->
        new_position != prev && grid[new_position] != "#" && grid[new_position] != nil
      end)

    if next == nil do
      distances
    else
      distances(grid, next, target, distances, {x, y})
    end
  end

  def get_cheats({grid, start, target}, min_saved_time, cheat_dist) do
    distances = distances(grid, start, target, %{start => 0})

    distances
    |> Enum.map(fn {{x_a, y_a}, dist_a} ->
      distances
      |> Enum.count(fn {{x_b, y_b}, dist_b} ->
        cheat_path = abs(x_a - x_b) + abs(y_a - y_b)
        dist_b - dist_a - cheat_path >= min_saved_time && cheat_path <= cheat_dist
      end)
    end)
    |> Enum.sum()
  end

  def part1(input) do
    parse_input(input) |> get_cheats(100, 2)
  end

  def part2(input) do
    parse_input(input) |> get_cheats(100, 20)
  end
end
