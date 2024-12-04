defmodule AdventOfCode.Day04 do
  def parse_input(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, i} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn {char, j} -> {{i, j}, char} end)
    end)
    |> Enum.into(%{})
  end

  def count_xmas({{x, y}, "X"}, grid) do
    for(dx <- -1..1, dy <- -1..1, do: {dx, dy})
    |> Enum.filter(&(&1 != {0, 0}))
    |> Enum.map(fn {dx, dy} ->
      Enum.map(0..3, fn i -> Map.get(grid, {x + i * dx, y + i * dy}, "") end) |> Enum.join()
    end)
    |> Enum.count(&(&1 == "XMAS"))
  end

  def is_mas_x_center({{x, y}, "A"}, grid) do
    a = Map.get(grid, {x - 1, y - 1}, "") <> "A" <> Map.get(grid, {x + 1, y + 1}, "")
    b = Map.get(grid, {x - 1, y + 1}, "") <> "A" <> Map.get(grid, {x + 1, y - 1}, "")

    (a == "MAS" || a == "SAM") && (b == "MAS" || b == "SAM")
  end

  def part1(input) do
    grid = parse_input(String.split(input, "\n", trim: true))

    grid
    |> Enum.filter(fn {{_, _}, char} -> char == "X" end)
    |> Enum.map(&count_xmas(&1, grid))
    |> Enum.sum()
  end

  def part2(input) do
    grid = parse_input(String.split(input, "\n", trim: true))

    grid
    |> Enum.filter(fn {{_, _}, char} -> char == "A" end)
    |> Enum.count(&is_mas_x_center(&1, grid))
  end
end
