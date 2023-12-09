defmodule Day9 do
  defp gen_next_nums nums do
    new = nums
    |> Enum.reverse
    |> hd
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce([], fn [x, y], acc -> 
      [(y - x) | acc]
    end)
    |> Enum.reverse
    n = [new | nums |> Enum.reverse]
    if Enum.all?(new, & &1 === 0) do
      n
    else
      n |> Enum.reverse |> gen_next_nums
    end
  end

  defp predict_last nums do
    gen_next_nums([nums])
    |> Enum.reduce(0, fn n, acc -> 
      x = n |> Enum.at(-1)
      acc + x
    end)
  end

  defp predict_first nums do
    gen_next_nums([nums])
    |> Enum.reduce(0, fn n, acc -> 
      x = n |> Enum.at(0)
      x - acc
    end)
  end

  defp parse_input line do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solution1 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_input/1)
      |> Enum.map(&predict_last/1)
      |> Enum.sum
      _ -> -1
    end
  end

  def solution2 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_input/1)
      |> Enum.map(&predict_first/1)
      |> Enum.sum
      _ -> -1
    end
  end
end

# IO.puts Day9.solution2 "./example.txt"
IO.puts Day9.solution2 "./input.txt"
