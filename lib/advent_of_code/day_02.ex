defmodule AdventOfCode.Day02 do
  def are_safe([head | tail]) do
    direction = if head > hd(tail), do: :down, else: :up
    are_safe(tail, head, direction)
  end

  def are_safe([head | _tail], prev, _) when abs(head - prev) > 3, do: false

  def are_safe([head | tail], prev, direction) do
    case {prev, head, direction} do
      {x, y, _} when x == y -> false
      {x, y, :up} when x > y -> false
      {x, y, :down} when x < y -> false
      _ -> are_safe(tail, head, direction)
    end
  end

  def are_safe([], _, _), do: true

  def are_safe_with_single_mistake(levels) do
    are_safe(levels) || are_safe_with_single_mistake([hd(levels)], tl(levels))
  end

  def are_safe_with_single_mistake(prev, []) do
    are_safe(Enum.drop(prev, -1))
  end

  def are_safe_with_single_mistake(prev, remaining) do
    are_safe(Enum.drop(prev, -1) ++ remaining) ||
      are_safe_with_single_mistake(prev ++ [hd(remaining)], tl(remaining))
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
