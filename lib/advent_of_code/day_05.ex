defmodule AdventOfCode.Day05 do
  def parse_input(input) do
    [rules, updates] = String.split(input, "\n\n")

    rules =
      String.split(rules, "\n", trim: true)
      |> Enum.map(fn rule ->
        String.split(rule, "|") |> Enum.map(&String.to_integer/1)
      end)

    updates =
      String.split(updates, "\n", trim: true)
      |> Enum.map(fn line ->
        String.split(line, ",")
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index()
        |> Enum.into(%{})
      end)

    {rules, updates}
  end

  def are_compliant?(pages, rules) do
    Enum.all?(rules, fn [a, b] -> pages[a] == nil || pages[b] == nil || pages[a] < pages[b] end)
  end

  def sum_middle_updates(filtered_updates) do
    Enum.map(filtered_updates, fn pages ->
      Enum.find(pages, fn {_, i} -> i == (map_size(pages) - 1) / 2 end) |> elem(0)
    end)
    |> Enum.sum()
  end

  def get_applicable_rules(pages, rules) do
    Enum.filter(rules, fn [a, b] ->
      Enum.any?(pages, fn {page, _i} -> page == a end) &&
        Enum.any?(pages, fn {page, _i} -> page == b end)
    end)
  end

  def fix_pages_order(pages, _, already_fixed) when pages == %{}, do: already_fixed

  def fix_pages_order(pages, rules, already_fixed) do
    {next_page, _} =
      Enum.find(pages, fn {page, _} -> !Enum.any?(rules, fn [_, b] -> page == b end) end)

    remaining_pages = Map.delete(pages, next_page)

    fix_pages_order(
      remaining_pages,
      get_applicable_rules(remaining_pages, rules),
      Map.put(already_fixed, next_page, map_size(already_fixed))
    )
  end

  def part1(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.filter(&are_compliant?(&1, rules))
    |> sum_middle_updates()
  end

  def part2(input) do
    {rules, updates} = parse_input(input)

    updates
    |> Enum.filter(fn pages -> !are_compliant?(pages, rules) end)
    |> Enum.map(fn pages -> fix_pages_order(pages, get_applicable_rules(pages, rules), %{}) end)
    |> sum_middle_updates()
  end
end
