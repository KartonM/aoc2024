defmodule AdventOfCode.Day03 do
  def part1(input) do
    Regex.scan(~r/mul\(\d+,\d+\)/, input)
    |> Enum.map(&Regex.scan(~r/\d+/, hd(&1)))
    |> Enum.map(fn [[x], [y]] -> String.to_integer(x)*String.to_integer(y) end)
    |> Enum.sum()
  end

  def part2(input) do
    String.split(input, "do()")
    |> Enum.map(fn s -> String.split(s, "don't()") |> hd() end)
    |> Enum.join()
    |> part1()
  end
end
