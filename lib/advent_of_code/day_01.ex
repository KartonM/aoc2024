defmodule AdventOfCode.Day01 do
  def parse_input(input) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, "   ") |> Enum.map(&String.to_integer/1) end)

    left = Enum.map(lines, fn [x, _] -> x end)
    right = Enum.map(lines, fn [_, y] -> y end)
    {left, right}
  end

  def part1(input) do
    {left, right} = parse_input(input) |> then(fn {l, r} -> {Enum.sort(l), Enum.sort(r)} end)
    Enum.zip(left, right) |> Enum.map(fn {x, y} -> abs(x - y) end) |> Enum.sum()
  end

  def part2(input) do
    {left, right} = parse_input(input)
    frequencies = Enum.frequencies(right)
    Enum.map(left, fn x -> x * Map.get(frequencies, x, 0) end) |> Enum.sum()
  end
end
