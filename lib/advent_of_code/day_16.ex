defmodule AdventOfCode.Day16 do
  def parse_input(input) do
    grid =
      String.split(input, "\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.filter(fn {char, _} -> char != "." end)
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Enum.into(%{})

    starting_pos = grid |> Enum.find(fn {{_, _}, char} -> char == "S" end) |> elem(0)
    end_pos = grid |> Enum.find(fn {{_, _}, char} -> char == "E" end) |> elem(0)
    w = grid |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    h = grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()
    {grid, starting_pos, end_pos, w, h}
  end

  def rotate_clockwise({dx, dy}) do
    {dy, -dx}
  end

  def rotate_counter_clockwise({dx, dy}) do
    {-dy, dx}
  end

  def cheapest_path_dijkstra(grid, {e_x, e_y}, queue, dist) do
    u =
      queue |> Enum.filter(fn v -> Map.has_key?(dist, v) end) |> Enum.min_by(fn v -> dist[v] end)

    if elem(u, 0) == {e_x, e_y} do
      dist[u]
    else
      queue = Enum.reject(queue, fn v -> v == u end)
      {{x, y}, {dx, dy}} = u

      dist =
        [
          {{{x + dx, y + dy}, {dx, dy}}, 1},
          {{{x, y}, rotate_clockwise({dx, dy})}, 1000},
          {{{x, y}, rotate_counter_clockwise({dx, dy})}, 1000}
        ]
        |> Enum.filter(fn {{{x, y}, dir}, _} ->
          Map.get(grid, {x, y}) != "#" && Enum.member?(queue, {{x, y}, dir})
        end)
        |> Enum.reduce(dist, fn {v, cost}, acc ->
          alt = dist[u] + cost
          if !Map.has_key?(acc, v) || alt < acc[v], do: Map.put(acc, v, alt), else: acc
        end)

      cheapest_path_dijkstra(grid, {e_x, e_y}, queue, dist)
    end
  end

  def generate_all_vertices(grid, w, h) do
    for x <- 0..w, y <- 0..h, dir <- [{1, 0}, {0, 1}, {-1, 0}, {0, -1}], grid[{x, y}] != "#" do
      {{x, y}, dir}
    end
  end

  def part1(input) do
    {grid, starting_pos, end_pos, w, h} = parse_input(input)

    cheapest_path_dijkstra(grid, end_pos, generate_all_vertices(grid, w, h), %{
      {starting_pos, {1, 0}} => 0
    })
  end

  def part2(_args) do
  end
end
