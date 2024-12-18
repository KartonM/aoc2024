defmodule AdventOfCode.Day17 do
  import Bitwise

  def parse_input(input) do
    [registers, program] =
      input |> String.trim("\n") |> String.split("\n\n") |> IO.inspect()

    registers =
      Enum.map(String.split(registers, "\n"), fn line ->
        [_, value] = String.split(line, ": ")
        String.to_integer(value)
      end)
      |> Enum.zip([:A, :B, :C])
      |> Enum.map(fn {value, index} -> {index, value} end)
      |> Enum.into(%{})

    program =
      String.split(program, ": ")
      |> Enum.at(1)
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {value, index} -> {index, value} end)
      |> Enum.into(%{})

    {registers, program}
  end

  def combo_operand_value(registers, value) do
    case value do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> registers[:A]
      5 -> registers[:B]
      6 -> registers[:C]
    end
  end

  def dv(registers, register, operand) do
    Map.put(
      registers,
      register,
      trunc(registers[:A] / :math.pow(2, combo_operand_value(registers, operand)))
    )
  end

  def execute(program, registers, pointer \\ 0, output \\ []) do
    operand = Map.get(program, pointer + 1)

    case Map.get(program, pointer) do
      nil ->
        {output, registers}

      0 ->
        registers = dv(registers, :A, operand)

        execute(program, registers, pointer + 2, output)

      1 ->
        registers = Map.update!(registers, :B, fn b -> bxor(b, operand) end)
        execute(program, registers, pointer + 2, output)

      2 ->
        registers = Map.put(registers, :B, rem(combo_operand_value(registers, operand), 8))
        execute(program, registers, pointer + 2, output)

      3 ->
        if registers[:A] == 0 do
          execute(program, registers, pointer + 2, output)
        else
          execute(program, registers, operand, output)
        end

      4 ->
        registers = Map.update!(registers, :B, fn b -> bxor(b, registers[:C]) end)
        execute(program, registers, pointer + 2, output)

      5 ->
        out = combo_operand_value(registers, operand) |> rem(8)
        execute(program, registers, pointer + 2, output ++ [out])

      6 ->
        registers = dv(registers, :B, operand)

        execute(program, registers, pointer + 2, output)

      7 ->
        registers = dv(registers, :C, operand)

        execute(program, registers, pointer + 2, output)
    end
  end

  def part1(input) do
    {registers, program} = parse_input(input)
    execute(program, registers) |> elem(0) |> Enum.join(",")
  end

  def triplets(arr) do
    Enum.reduce(arr, 0, fn x, acc -> acc * 8 + x end)
  end

  def find_input(program, solution, current \\ nil) do
    if current == nil do
      0..7 |> Enum.find_value(fn a -> find_input(program, solution, [a]) end)
    else
      res = execute(program, %{A: triplets(current), B: 0, C: 0}) |> elem(0)

      cond do
        res == solution ->
          current

        res == Enum.take(solution, -1 * length(res)) ->
          0..7 |> Enum.find_value(fn a -> find_input(program, solution, current ++ [a]) end)

        true ->
          nil
      end
    end
  end

  def part2(input) do
    {_, program} = parse_input(input)

    solution = program |> Enum.sort_by(&elem(&1, 0)) |> Enum.map(&elem(&1, 1))
    find_input(program, solution) |> triplets()
  end
end
