defmodule Mix.Tasks.D19.P2 do
  use Mix.Task

  import AdventOfCode.Day19

  @shortdoc "Day 19 Part 2"
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)
    input = AdventOfCode.Input.get!(19, 2024)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
