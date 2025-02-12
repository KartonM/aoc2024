defmodule Mix.Tasks.D19.P1 do
  use Mix.Task

  import AdventOfCode.Day19

  @shortdoc "Day 19 Part 1"
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)
    input = AdventOfCode.Input.get!(19, 2024)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
