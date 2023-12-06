defmodule Day4 do
  defp nums_to_set nums do
    nums
    |> String.split(" ")
    |> Enum.map(&Integer.parse/1)
    |> Enum.filter(& &1 !== :error)
    |> Enum.map(fn {x, _} -> x end)
    |> MapSet.new
  end

  defp parse_line line do
    [_, nums] = String.split(line, ": ")
    nums = String.trim(nums)
    [winning, ours] = String.split(nums, " | ")
    MapSet.intersection(nums_to_set(winning), nums_to_set(ours))
    |> MapSet.to_list
  end

  defp count_cards base, left_to_eval do
    case left_to_eval do
      [head | tail] ->
        {num, idx} = head
        if num === 0 do
          [head] ++ count_cards(base, tail)
        else
          extra = for n <- 1..num do Enum.at(base, n + idx) end
          [head] ++ count_cards(base, tail) ++ count_cards(base, extra)
        end
      _ -> []
    end
  end

  defp count_cards cards do
    count_cards(cards, cards)
  end

  def solution1 file do
    {result, content} = File.read file
    case result do
    :ok -> content
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> Enum.map(&length/1)
      |> Enum.filter(& &1 !== 0)
      |> Enum.map(& 2 ** (&1 - 1))
      |> Enum.sum
    _ -> -1
    end
  end

  def solution2 file do
    {result, content} = File.read file
    case result do
    :ok -> content
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> Enum.map(&length/1)
      |> Enum.with_index
      |> count_cards
      |> length
    _ -> -1
    end
  end
end

# IO.puts Day4.solution2 "./example.txt"
IO.puts Day4.solution2 "./input.txt"
