defmodule AdventOfCode.Day18 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
  end

  def grid_after(falling_bytes, seconds, size) do
    grid = for(y <- 0..(size - 1), x <- 0..(size - 1), do: {{x, y}, "."}) |> Enum.into(%{})

    falling_bytes
    |> Enum.take(seconds)
    |> Enum.reduce(grid, fn {x, y}, acc -> Map.put(acc, {x, y}, "#") end)
  end

  def print_grid(grid, size) do
    Enum.reduce(0..(size - 1), "", fn y, acc ->
      Enum.reduce(0..(size - 1), acc, fn x, acc ->
        acc <> grid[{x, y}]
      end) <> "\n"
    end)
    |> IO.puts()
  end

  def h({x, y}, size) do
    size - x - 1 + size - y - 1
  end

  def shortest_path_a_star(grid, size, open_set, g_score, f_score, target) do
    current = Enum.min_by(open_set, fn {x, y} -> f_score[{x, y}] end, fn -> nil end)

    case current do
      nil ->
        nil

      ^target ->
        f_score[target]

      {x, y} ->
        open_set = MapSet.delete(open_set, current)

        {open_set, f_score, g_score} =
          [
            {x + 1, y},
            {x - 1, y},
            {x, y + 1},
            {x, y - 1}
          ]
          |> Enum.filter(fn neighbour -> grid[neighbour] == "." end)
          |> Enum.reduce({open_set, f_score, g_score}, fn {x, y}, {open_set, f_score, g_score} ->
            tentative_g_score = g_score[current] + 1

            if g_score[{x, y}] == nil || tentative_g_score < g_score[{x, y}] do
              open_set = MapSet.put(open_set, {x, y})
              g_score = Map.put(g_score, {x, y}, tentative_g_score)
              f_score = Map.put(f_score, {x, y}, tentative_g_score + h({x, y}, size))
              {open_set, f_score, g_score}
            else
              {open_set, f_score, g_score}
            end
          end)

        shortest_path_a_star(grid, size, open_set, g_score, f_score, target)
    end
  end

  def shortest_path_a_star(grid, size) do
    shortest_path_a_star(
      grid,
      size,
      MapSet.new([{0, 0}]),
      %{{0, 0} => 0},
      %{
        {0, 0} => h({0, 0}, size)
      },
      {size - 1, size - 1}
    )
  end

  def part1(input, seconds, size) do
    falling_bytes = parse_input(input)
    grid_after(falling_bytes, seconds, size) |> shortest_path_a_star(size)
  end

  def part2(input, size) do
    falling_bytes = parse_input(input)

    Enum.find(1024..length(falling_bytes), fn seconds ->
      grid_after(falling_bytes, seconds, size) |> shortest_path_a_star(size) == nil
    end) |> then(fn second -> Enum.at(falling_bytes, second - 1) |> Tuple.to_list() |> Enum.join(",") end)
  end
end
