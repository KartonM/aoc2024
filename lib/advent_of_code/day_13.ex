defmodule AdventOfCode.Day13 do
  def parse_input(input) do
    input
    |> String.trim("\n")
    |> String.split("\n\n")
    |> Enum.map(fn group ->
      String.split(group, "\n")
      |> Enum.map(fn line ->
        Regex.scan(~r/\d+/, line)
        |> Enum.map(&hd(&1))
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> List.to_tuple()
    end)
  end

  def round_integer(n) when is_number(n) do
    if abs(n - round(n)) < 0.0001, do: round(n), else: n
  end

  def round_integer({a, b}) do
    {round_integer(a), round_integer(b)}
  end

  def token_cost({a, b}) do
    3 * a + b
  end

  def count_tokens_to_win({{x1, y1}, {x2, y2}, {prize_x, prize_y}}) do
    b = (prize_y - y1 / x1 * prize_x) / (y2 - y1 / x1 * x2)
    a = (prize_x - x2 * b) / x1

    [
      {a, b},
      if(prize_x / x1 == prize_y / y1, do: {prize_y / y1, 0}),
      if(prize_x / x2 == prize_y / y2, do: {0, prize_y / y2})
    ]
    |> Enum.filter(& &1)
    |> Enum.map(&round_integer/1)
    |> Enum.filter(fn {a, b} -> is_integer(a) && is_integer(b) end)
    |> Enum.min_by(&token_cost/1, fn -> {0, 0} end)
  end

  def part1(input) do
    parse_input(input)
    |> Enum.map(&count_tokens_to_win/1)
    |> Enum.map(&token_cost/1)
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> Enum.map(fn {a, b, {prize_x, prize_y}} ->
      {a, b, {prize_x + 10_000_000_000_000, prize_y + 10_000_000_000_000}}
    end)
    |> Enum.map(&count_tokens_to_win/1)
    |> Enum.map(&token_cost/1)
    |> Enum.sum()
  end
end
