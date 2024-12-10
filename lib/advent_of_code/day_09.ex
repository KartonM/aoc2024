defmodule AdventOfCode.Day09 do
  def parse_input(input) do
    String.trim(input, "\n")
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.map(fn {length, i} ->
      if rem(i, 2) == 0 do
        %{type: :file, length: length, id: div(i, 2)}
      else
        %{type: :gap, length: length}
      end
    end)
    |> Enum.filter(fn item -> item[:type] != :gap || item[:length] > 0 end)
    |> :queue.from_list()
  end

  def remove_first_bits_of_last_file(list, gap_length) do
    if :queue.get_r(list).type == :gap do
      remove_first_bits_of_last_file(:queue.liat(list), gap_length)
    else
      {{:value, file}, remaining} = :queue.out_r(list)

      if file.length > gap_length do
        {Map.put(file, :length, gap_length),
         :queue.in(Map.put(file, :length, file.length - gap_length), remaining)}
      else
        {file, remaining}
      end
    end
  end

  def fill_gaps(remaining, preceding \\ :queue.new()) do
    cond do
      :queue.is_empty(remaining) ->
        preceding

      :queue.head(remaining)[:type] == :file ->
        fill_gaps(:queue.tail(remaining), :queue.in(:queue.head(remaining), preceding))

      :queue.tail(remaining) |> :queue.is_empty() ->
        preceding

      true ->
        {{:value, %{length: gap_length}}, tail} = :queue.out(remaining)

        {%{length: file_length, id: file_id}, tail_with_gap_removed} =
          remove_first_bits_of_last_file(tail, gap_length)

        preceding = :queue.in(%{type: :file, length: file_length, id: file_id}, preceding)

        if gap_length > file_length do
          fill_gaps(
            :queue.in_r(%{type: :gap, length: gap_length - file_length}, tail_with_gap_removed),
            preceding
          )
        else
          fill_gaps(tail_with_gap_removed, preceding)
        end
    end
  end

  def split_at_last_unchecked_file(disk, tail \\ :queue.new()) do
    if :queue.is_empty(disk) do
      :all_checked
    else
      {{:value, file_or_gap}, remaining} = :queue.out_r(disk)

      if file_or_gap.type == :gap || Map.has_key?(file_or_gap, :checked) do
        split_at_last_unchecked_file(remaining, :queue.in_r(file_or_gap, tail))
      else
        {remaining, file_or_gap, tail}
      end
    end
  end

  def split_at_gap_of_size(disk, gap_size, preceding \\ :queue.new()) do
    if :queue.is_empty(disk) do
      :gap_not_found
    else
      {{:value, file_or_gap}, remaining} = :queue.out(disk)

      if file_or_gap.type == :gap && file_or_gap.length >= gap_size do
        {preceding, file_or_gap, remaining}
      else
        split_at_gap_of_size(remaining, gap_size, :queue.in(file_or_gap, preceding))
      end
    end
  end

  def move_last_unchecked_file(disk) do
    case split_at_last_unchecked_file(disk) do
      :all_checked ->
        {:done, disk}

      {preceding, file_to_move, tail} ->
        case split_at_gap_of_size(preceding, file_to_move.length) do
          :gap_not_found ->
            {:checked,
             Map.put(file_to_move, :checked, true) |> :queue.in(preceding) |> :queue.join(tail)}

          {gap_preceding, gap, gap_tail} ->
            remaining_gap =
              if gap.length - file_to_move.length > 0,
                do: :queue.from_list([%{type: :gap, length: gap.length - file_to_move.length}]),
                else: :queue.new()

            {:checked,
             Map.put(file_to_move, :checked, true)
             |> :queue.in(gap_preceding)
             |> :queue.join(remaining_gap)
             |> :queue.join(gap_tail)
             |> :queue.join(:queue.from_list([%{type: :gap, length: file_to_move.length}]))
             |> :queue.join(tail)}
        end
    end
  end

  def move_files(d) do
#    IO.inspect(
#      d
#      |> :queue.to_list()
#      |> Enum.reduce([], fn file_or_gap, acc ->
#        acc ++
#          List.duplicate(
#            if(file_or_gap.type == :file, do: file_or_gap.id, else: "."),
#            file_or_gap.length
#          )
#      end)
#      |> Enum.join()
#    )

    case move_last_unchecked_file(d) do
      {:done, disk} ->
        disk

      {:checked, disk} ->
        move_files(disk)
    end
  end

  def part1(input) do
    parse_input(input)
    |> fill_gaps()
    |> :queue.to_list()
    |> Enum.reduce([], fn file, acc -> acc ++ List.duplicate(file.id, file.length) end)
    |> Enum.with_index()
    |> Enum.map(fn {value, i} -> value * i end)
    |> Enum.sum()
  end

  def part2(input) do
    parse_input(input)
    |> move_files()
    |> :queue.to_list()
    |> Enum.reduce([], fn file_or_gap, acc ->
      acc ++
        List.duplicate(
          if(file_or_gap.type == :gap, do: 0, else: file_or_gap.id),
          file_or_gap.length
        )
    end)
    |> Enum.with_index()
    |> Enum.map(fn {value, i} -> value * i end)
    |> Enum.sum()
  end
end
