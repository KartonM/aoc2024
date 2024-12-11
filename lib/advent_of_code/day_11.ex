defmodule AdventOfCode.Day11 do
  use Memoize

  def parse_input(input) do
    input
    |> String.trim("\n")
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  def split(string) do
    middle_index = div(String.length(string), 2)

    {String.slice(string, 0, middle_index) |> String.to_integer(),
     String.slice(string, middle_index, String.length(string)) |> String.to_integer()}
  end

  defmemo count_stones_after_blinks(_, 0), do: 1

  defmemo count_stones_after_blinks(stone, n) do
    string = Integer.to_string(stone)

    cond do
      stone == 0 ->
        count_stones_after_blinks(1, n - 1)

      rem(String.length(string), 2) == 0 ->
        {left, right} = split(string)
        count_stones_after_blinks(left, n - 1) + count_stones_after_blinks(right, n - 1)

      true ->
        count_stones_after_blinks(stone * 2024, n - 1)
    end
  end

  def part1(input) do
    parse_input(input)
    |> Enum.map(&count_stones_after_blinks(&1, 25))
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.map(&count_stones_after_blinks(&1, 75))
    |> Enum.sum()
  end
end
