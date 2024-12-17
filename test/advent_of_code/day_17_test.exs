defmodule AdventOfCode.Day17Test do
  use ExUnit.Case

  import AdventOfCode.Day17

  test "part1" do
    input = "
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"
    result = part1(input)

    assert result == "4,6,3,5,6,3,5,2,1,0"
  end

  test "part1 a" do
    input = "
Register A: 0
Register B: 0
Register C: 9

Program: 2,6"
    result = part1(input)

    assert result == ""
  end

  test "part1 b" do
    input = "
Register A: 10
Register B: 0
Register C: 0

Program: 5,0,5,1,5,4"
    result = part1(input)

    assert result == "0,1,2"
  end

  test "part1 c" do
    input = "
Register A: 2024
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"
    result = part1(input)

    assert result == "4,2,5,6,7,7,7,7,3,1,0"
  end

  test "part1 d" do
    input = "
Register A: 0
Register B: 29
Register C: 0

Program: 1,7"
    result = part1(input)

    assert result == ""
  end

  test "part1 e" do
    input = "
Register A: 0
Register B: 2024
Register C: 43690

Program: 4,0"
    result = part1(input)

    assert result == ""
  end

  @tag :skip
  test "part2" do
    input = nil
    result = part2(input)

    assert result
  end
end
