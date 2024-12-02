defmodule AdventOfCode.Day02 do
  def are_safe(levels) do
    diffs = Enum.chunk_every(levels, 2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
    Enum.any?([1..3, -3..-1], fn range -> Enum.all?(diffs, fn diff -> diff in range end) end)
  end

  def drop_at(list, index) do
    {left, [_ | right]} = Enum.split(list, index)
    left ++ right
  end

  def are_safe_with_single_mistake(levels) do
    are_safe(levels) ||
      Enum.any?(0..(length(levels) - 1), fn index -> are_safe(drop_at(levels, index)) end)
  end

  def parse_levels(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line) |> Enum.map(&String.to_integer/1) end)
  end

  def part1(input) do
    parse_levels(input)
    |> Enum.count(&are_safe/1)
  end

  def part2(input) do
    parse_levels(input)
    |> Enum.count(&are_safe_with_single_mistake/1)
  end
end
