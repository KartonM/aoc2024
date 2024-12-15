defmodule AdventOfCode.Day15 do
  def parse_input(input) do
    [grid, directions] = String.split(input, "\n\n", trim: true)

    grid =
      String.split(grid, "\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.filter(fn {char, _} -> char != "." end)
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
      end)
      |> Enum.into(%{})

    directions =
      directions
      |> String.split("\n", trim: true)
      |> Enum.flat_map(&String.graphemes/1)
      |> Enum.map(fn dir ->
        case dir do
          "^" -> {0, -1}
          "v" -> {0, 1}
          "<" -> {-1, 0}
          ">" -> {1, 0}
        end
      end)

    {grid, directions}
  end

  def get_first_free(grid, {x, y}, {dx, dy}) do
    next_pos = {x + dx, y + dy}

    case Map.get(grid, next_pos) do
      nil -> next_pos
      "#" -> nil
      "O" -> get_first_free(grid, next_pos, {dx, dy})
    end
  end

  def print_grid(grid, {w, h}) do
    Enum.reduce(0..(h - 1), "", fn y, acc ->
      Enum.reduce(0..(w - 1), acc, fn x, acc ->
        case grid[{x, y}] do
          nil -> acc <> "."
          char -> acc <> char
        end
      end) <> "\n"
    end)
    |> IO.puts()
  end

  def get_large_box_at_position(grid, {x, y}) do
    case grid[{x, y}] do
      "[" -> [{x, y}, {x + 1, y}]
      "]" -> [{x - 1, y}, {x, y}]
    end
  end

  def get_large_boxes_to_push(grid, {x, y}, {dx, dy}, boxes \\ nil) do
    cond do
      boxes == nil ->
        get_large_boxes_to_push(grid, {x, y}, {dx, dy}, [
          get_large_box_at_position(grid, {x + dx, y + dy})
        ])

      Enum.any?(List.flatten(boxes), fn {x, y} -> grid[{x + dx, y + dy}] == "#" end) ->
        nil

      true ->
        boxes_to_push =
          boxes
          |> List.flatten()
          |> Enum.map(fn {x, y} -> {x + dx, y + dy} end)
          |> Enum.filter(fn pos_in_front ->
            grid[pos_in_front] != nil &&
              !Enum.any?(boxes, fn [l, r] -> l == pos_in_front || r == pos_in_front end)
          end)
          |> Enum.map(&get_large_box_at_position(grid, &1))
          |> Enum.uniq()

        if boxes_to_push == [] do
          boxes
        else
          get_large_boxes_to_push(grid, {x, y}, {dx, dy}, boxes ++ boxes_to_push)
        end
    end
  end

  def move_boxes(grid, boxes, {dx, dy}) do
    grid =
      Enum.reduce(boxes, grid, fn [l, r], grid ->
        grid
        |> Map.delete(l)
        |> Map.delete(r)
      end)

    Enum.reduce(boxes, grid, fn [{l_x, l_y}, {r_x, r_y}], grid ->
      grid
      |> Map.put({l_x + dx, l_y + dy}, "[")
      |> Map.put({r_x + dx, r_y + dy}, "]")
    end)
  end

  def part1(input) do
    {grid, directions} = parse_input(input)
#    width = input |> String.split("\n", trim: true) |> hd() |> String.length()
    starting_pos = grid |> Enum.find(fn {{_, _}, char} -> char == "@" end) |> elem(0)

    {grid, _} =
      directions
      |> Enum.reduce({grid, starting_pos}, fn {dx, dy}, {grid, {x, y}} ->
        #        print_grid(grid, {width, width})
        #        IO.inspect({{x, y}, {dx, dy}})
        #        IO.puts("\n")
        new_pos = {x + dx, y + dy}

        case Map.get(grid, new_pos) do
          nil ->
            {grid |> Map.delete({x, y}) |> Map.put(new_pos, "@"), new_pos}

          "#" ->
            {grid, {x, y}}

          "O" ->
            first_free = get_first_free(grid, new_pos, {dx, dy})

            if first_free == nil do
              {grid, {x, y}}
            else
              {grid |> Map.delete({x, y}) |> Map.put(new_pos, "@") |> Map.put(first_free, "O"),
               new_pos}
            end
        end
      end)

    grid
    |> Enum.filter(fn {{_, _}, char} -> char == "O" end)
    |> Enum.map(fn {{x, y}, _} -> x + y * 100 end)
    |> Enum.sum()
  end

  def part2(input) do
    {grid, directions} = parse_input(input)
#    h = input |> String.split("\n", trim: true) |> hd() |> String.length()

    grid =
      grid
      |> Enum.flat_map(fn {{x, y}, char} ->
        case char do
          "#" -> [{{x * 2, y}, "#"}, {{x * 2 + 1, y}, "#"}]
          "O" -> [{{x * 2, y}, "["}, {{x * 2 + 1, y}, "]"}]
          "@" -> [{{x * 2, y}, "@"}]
        end
      end)
      |> Enum.into(%{})

    starting_pos = grid |> Enum.find(fn {{_, _}, char} -> char == "@" end) |> elem(0)

    {grid, _} =
      directions
      |> Enum.reduce({grid, starting_pos}, fn {dx, dy}, {grid, {x, y}} ->
        #        IO.puts("\n")
        #        print_grid(grid, {2 * h, h})
        #        IO.inspect({{x, y}, {dx, dy}})
        new_pos = {x + dx, y + dy}

        case Map.get(grid, new_pos) do
          nil ->
            {grid |> Map.delete({x, y}) |> Map.put(new_pos, "@"), new_pos}

          "#" ->
            {grid, {x, y}}

          # "[" or "]"
          _ ->
            boxes_to_push = get_large_boxes_to_push(grid, {x, y}, {dx, dy})

            if boxes_to_push == nil do
              {grid, {x, y}}
            else
              grid =
                grid
                |> move_boxes(boxes_to_push, {dx, dy})
                |> Map.delete({x, y})
                |> Map.put(new_pos, "@")

              {grid, new_pos}
            end
        end
      end)

    #    print_grid(grid, {2 * h, h})
    grid
    |> Enum.filter(fn {{_, _}, char} -> char == "[" end)
    |> Enum.map(fn {{x, y}, _} -> x + y * 100 end)
    |> Enum.sum()
  end
end
