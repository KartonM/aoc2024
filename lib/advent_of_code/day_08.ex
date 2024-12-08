defmodule AdventOfCode.Day08 do
  def parse_input(input) do
    lines = String.split(input, "\n", trim: true)
    height = Enum.count(lines)
    width = lines |> Enum.at(0) |> String.length()

    antennas =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} -> {{x, y}, char} end)
        |> Enum.filter(&(elem(&1, 1) != "."))
      end)
      |> Enum.group_by(fn {_, char} -> char end, &elem(&1, 0))

    {width, height, antennas}
  end

  def unique_pairs(list) do
    for x <- list |> Enum.with_index(),
        y <- list |> Enum.with_index(),
        elem(x, 1) < elem(y, 1),
        do: {elem(x, 0), elem(y, 0)}
  end

  def is_valid_antinode({x, y}, xBounds, yBounds) do
    is_integer(x) && is_integer(y) && x in xBounds && y in yBounds
  end

  def count_anitinodes(input, get_range) do
    {width, height, antennas} = parse_input(input)
    xBounds = 0..(width - 1)
    yBounds = 0..(height - 1)

    antennas
    |> Enum.flat_map(fn {_, locations} ->
      unique_pairs(locations)
      |> Enum.flat_map(fn {{x1, y1}, {x2, y2}} ->
        {dx, dy} = {x2 - x1, y2 - y1}

        get_range.(width)
        |> Enum.map(fn i -> {x1 + i * dx, y1 + i * dy} end)
        |> Enum.filter(&is_valid_antinode(&1, xBounds, yBounds))
      end)
    end)
    |> Enum.uniq()
    |> Enum.count()
  end

  def part1(input) do
    count_anitinodes(input, fn _ -> [-1, 2] end)
  end

  def part2(input) do
    count_anitinodes(input, fn width -> -width..width end)
  end
end
