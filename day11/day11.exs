defmodule Day11 do
  # part 1
  # @expand_times 2

  # part 2
  @expand_times 1_000_000

  defp transpose l do
    l |> Enum.zip |> Enum.map(&Tuple.to_list/1)
  end

  defp expand lines, n do
    lines
    |> Enum.reduce([], fn ln, acc -> 
        if Enum.all?(ln, & &1 === ".") do
          n = for _ <- 1..n do
            ln
          end
          n ++ acc
        else 
          [ln | acc]
        end
      end)
    |> Enum.reverse
  end

  defp find_hashes lines do
    lines
    |> Enum.with_index
    |> Enum.reduce([], fn {line, y}, acc -> 
      a = Enum.reduce(Enum.with_index(line), [], fn {char, x}, a -> 
        if(char === "#", do: [[x, y] | a], else: a) 
      end)
      a ++ acc
    end)
  end

  defp make_pairs lst do
    case lst do
      [_] -> []
      [head | tail] -> 
        p = for x <- tail do {head, x} end
        p ++ make_pairs tail
    end
  end

  defp get_distances lines do
    lines
    |> find_hashes
    |> make_pairs
    |> Enum.map(fn {[sx, sy], [tx, ty]} -> abs(sx - tx) + abs(sy - ty) end)
  end

  def solution file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> Enum.map(&String.graphemes/1)
      |> expand(@expand_times)
      |> transpose
      |> expand(@expand_times)
      |> transpose
      # |> Enum.map(&Enum.join(&1, ""))
      # |> Enum.join("\n")
      |> get_distances 
      |> Enum.sum
      _ -> -1
    end
  end
end

# IO.puts Day11.solution "./example.txt"
IO.puts Day11.solution "./input.txt"
