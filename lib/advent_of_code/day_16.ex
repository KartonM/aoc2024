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
    {grid, starting_pos, end_pos}
  end

  def rotate_clockwise({dx, dy}) do
    {dy, -dx}
  end

  def rotate_counter_clockwise({dx, dy}) do
    {-dy, dx}
  end

  def cheapest_path_dijkstra(
        grid,
        {e_x, e_y},
        queue,
        dist,
        cheapest_paths \\ [],
        lowest_cost \\ nil
      ) do
    if Enum.empty?(queue) do
      {cheapest_paths, lowest_cost}
    else
      {[u | rest], cost} = queue |> Enum.min_by(fn {_, cost} -> cost end)
      queue = Enum.reject(queue, fn v -> v == {[u | rest], cost} end)
      {{x, y}, {dx, dy}} = u

      cond do
        lowest_cost != nil && cost > lowest_cost ->
          {cheapest_paths, lowest_cost}

        {x, y} == {e_x, e_y} ->
          if lowest_cost == nil || cost < lowest_cost do
            cheapest_path_dijkstra(grid, {e_x, e_y}, queue, dist, [[u | rest]], cost)
          else
            cheapest_path_dijkstra(
              grid,
              {e_x, e_y},
              queue,
              dist,
              [[u | rest] | cheapest_paths],
              lowest_cost
            )
          end

        true ->
          {dist, queue} =
            [
              {{{x + dx, y + dy}, {dx, dy}}, 1},
              {{{x, y}, rotate_clockwise({dx, dy})}, 1000},
              {{{x, y}, rotate_counter_clockwise({dx, dy})}, 1000}
            ]
            |> Enum.filter(fn {{{x, y}, dir}, _} ->
              Map.get(grid, {x, y}) != "#" && !Enum.member?(rest, {{x, y}, dir})
            end)
            |> Enum.reduce({dist, queue}, fn {v, v_cost}, {dist, queue} ->
              alt = cost + v_cost

              if !Map.has_key?(dist, v) || alt <= dist[v] do
                {Map.put(dist, v, alt), [{[v | [u | rest]], alt} | queue]}
              else
                {dist, queue}
              end
            end)

          cheapest_path_dijkstra(
            grid,
            {e_x, e_y},
            queue,
            dist,
            cheapest_paths,
            lowest_cost
          )
      end
    end
  end

  def part1(input) do
    {grid, starting_pos, end_pos} = parse_input(input)
    starting_vertex = {starting_pos, {1, 0}}

    cheapest_path_dijkstra(
      grid,
      end_pos,
      [{[starting_vertex], 0}],
      %{
        starting_vertex => 0
      },
      MapSet.new([starting_vertex])
    )
    |> elem(1)
  end

  def part2(input) do
    {grid, starting_pos, end_pos} = parse_input(input)
    starting_vertex = {starting_pos, {1, 0}}

    cheapest_path_dijkstra(
      grid,
      end_pos,
      [{[starting_vertex], 0}],
      %{
        starting_vertex => 0
      },
      MapSet.new([starting_vertex])
    )
    |> elem(0)
    |> Enum.flat_map(fn path -> Enum.map(path, fn {pos, _} -> pos end) end)
    |> Enum.uniq()
    |> Enum.count()
  end
end
