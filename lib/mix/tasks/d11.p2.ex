defmodule Mix.Tasks.D11.P2 do
  use Mix.Task

  import AdventOfCode.Day11

  @shortdoc "Day 11 Part 2"
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)
    input = AdventOfCode.Input.get!(11, 2024)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
