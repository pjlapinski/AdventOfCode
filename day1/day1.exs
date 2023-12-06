defmodule Day1 do
  defp replace_text(text, with_num, index, length) do
    {head, tail} = String.split_at(text, index)
    {_, tail} = String.split_at(tail, length - 1)
    "#{head}#{with_num}#{tail}"
  end

  defp text_to_num text do
    nums = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    result = nums
    |> Enum.with_index
    |> Enum.map(fn {n, idx} -> {idx, :binary.matches(text, n)} end)
    |> Enum.filter(fn {_, res} -> length(res) !== 0 end)
    |> Enum.flat_map(fn {n, res} -> Enum.map(res, fn r -> {n, r} end) end)
    |> Enum.min_max_by(fn {_, {idx, _}} -> idx end, fn -> nil end)


    case result do 
      {{min_i, {min_mi, min_ml}}, {max_i, {max_mi, max_ml}}} -> 
        txt = replace_text(text, max_i, max_mi, max_ml)
        txt = if min_mi == max_mi do txt else replace_text(txt, min_i, min_mi, min_ml) end
        txt
      nil -> text
    end
  end

  defp first_and_last list do
    [10 * Enum.at(list, 0), Enum.at(list, -1)]
  end

  defp parse_line line do
    line 
    |> String.split("") 
    |> Enum.map(&Integer.parse/1) 
    |> Enum.filter(&(&1 !== :error))
    |> Enum.map(fn {i, _} -> i end)
    |> Enum.reduce([], &[&1 | &2])
    |> Enum.reverse
    |> first_and_last
    |> Enum.sum
  end

  def solution do
    {result, content} = File.read "./input.txt"
    case result do
      :ok -> content
        |> String.split("\n", trim: true)
        |> Enum.map(&text_to_num/1)
        |> Enum.map(&parse_line/1)
        |> Enum.sum
      _ -> -1
    end
  end
end

IO.puts Day1.solution
