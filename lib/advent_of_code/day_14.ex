defmodule AdventOfCode.Day14 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [x, y, v_x, v_y] =
        Regex.scan(~r/-?\d+/, line)
        |> Enum.map(&hd(&1))
        |> Enum.map(&String.to_integer/1)

      {{x, y}, {v_x, v_y}}
    end)
  end

  def mod(a, n) when n > 0 do
    rem = rem(a, n)
    if rem < 0, do: rem + n, else: rem
  end

  def position_after_seconds({{x, y}, {v_x, v_y}}, seconds, {w, h}) do
    {mod(x + v_x * seconds, w), mod(y + v_y * seconds, h)}
  end

  def get_quadrant({x, y}, {w, h}) do
    cond do
      x < div(w, 2) and y < div(h, 2) -> 1
      x > div(w, 2) and y < div(h, 2) -> 2
      x < div(w, 2) and y > div(h, 2) -> 3
      x > div(w, 2) and y > div(h, 2) -> 4
      true -> :middle
    end
  end

  def print(robots, {w, h}) do
    Enum.reduce(0..(h - 1), "", fn y, acc ->
      Enum.reduce(0..(w - 1), acc, fn x, acc ->
        cond do
#          y == div(h, 2) || x == div(w, 2) -> acc <> " "
          Enum.any?(robots, fn {{r_x, r_y}, _} -> r_x == x and r_y == y end) -> acc <> "#"
          true -> acc <> "."
        end
      end)
      |> Kernel.<>("\n")
    end)
  end

  def part1(input, {w, h}) do
    parse_input(input)
    |> Enum.map(fn {pos, v} -> position_after_seconds({pos, v}, 100, {w, h}) end)
    |> Enum.group_by(&get_quadrant(&1, {w, h}))
    |> IO.inspect()
    |> Enum.filter(fn {k, _} -> k != :middle end)
    |> Enum.map(fn {_, v} -> Enum.count(v) end)
    |> Enum.reduce(&(&1 * &2))
  end

  def possible_tree?(quadrants) do
    r1 =
      round(
        (Map.get(quadrants, 1, []) |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.count()) /
          (Map.get(quadrants, 3, []) |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.count()) *
          100
      )

    r2 =
      round(
        (Map.get(quadrants, 2, []) |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.count()) /
          (Map.get(quadrants, 4, []) |> Enum.map(&elem(&1, 0)) |> Enum.uniq() |> Enum.count()) *
          100
      )

    #    IO.inspect({r1, r2})

    range = 0..85
    r1 in range && r2 in range
  end

  def part2(input, {w, h}) do
    r = parse_input(input)

    156..11_1111//103
    |> Enum.reduce({MapSet.new(), ""}, fn seconds, {seen, log} ->
      robots =
        Enum.map(r, fn {pos, v} -> {position_after_seconds({pos, v}, seconds, {w, h}), v} end)

      # |> IO.inspect()
      quadrants = Enum.group_by(robots, &get_quadrant(elem(&1, 0), {w, h}))

      if possible_tree?(quadrants) do
#        IO.inspect(quadrants)
        IO.puts("Seconds: #{seconds}")
        IO.puts(print(robots, {w, h}))
      end

      if MapSet.member?(seen, robots) do
        IO.puts(log)
        throw(:done)
      end

            IO.puts("Seconds: #{seconds}")
            print(robots, {w, h}) |> IO.puts()
      #      {MapSet.put(seen, robots), log <> "\nSeconds: #{seconds}\n" <> print(robots, {w, h})}
      {MapSet.put(seen, robots), log}
    end)
  end
end
