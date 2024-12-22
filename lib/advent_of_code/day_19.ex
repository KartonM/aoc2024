defmodule AdventOfCode.Day19 do
  use Memoize

  def parse_input(input) do
    [towels, patterns] =
      input
      |> String.trim()
      |> String.split("\n\n", trim: true)

    {towels |> String.split(", ") |> MapSet.new(), patterns |> String.split("\n")}
  end

  defmemo count_arrangements(pattern, towels) do
    if String.length(pattern) == 0 do
      1
    else
      Enum.map(towels, fn towel ->
        {prefix, suffix} = String.split_at(pattern, String.length(towel))
        if prefix == towel, do: count_arrangements(suffix, towels), else: 0
      end)
      |> Enum.sum()
    end
  end

  def part1(input) do
    {towels, patterns} = parse_input(input)

    patterns |> Enum.map(&count_arrangements(&1, towels)) |> Enum.count(&(&1 > 0))
  end

  def part2(input) do
    {towels, patterns} = parse_input(input)

    patterns |> Enum.map(&count_arrangements(&1, towels)) |> Enum.sum()
  end
end
