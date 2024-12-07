defmodule AdventOfCode.Day07 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [res, values] = String.split(line, ": ")
      values = Enum.map(String.split(values, " "), &String.to_integer/1)
      {String.to_integer(res), values}
    end)
  end

  def concat(a, b), do: String.to_integer(Integer.to_string(a) <> Integer.to_string(b))

  def can_be_made_true({res, [next | rest]}, allow_concat),
    do: can_be_made_true({res, rest}, next, allow_concat)

  def can_be_made_true({res, []}, current_res, _), do: res == current_res
  def can_be_made_true({res, _}, current_res, _) when current_res > res, do: false

  def can_be_made_true({res, [next | rest]}, current_res, allow_concat) do
    can_be_made_true({res, rest}, current_res + next, allow_concat) ||
      can_be_made_true({res, rest}, current_res * next, allow_concat) ||
      (allow_concat && can_be_made_true({res, rest}, concat(current_res, next), allow_concat))
  end

  def part1(input) do
    parse_input(input)
    |> Enum.filter(&can_be_made_true(&1, false))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.filter(&can_be_made_true(&1, true))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end
end
