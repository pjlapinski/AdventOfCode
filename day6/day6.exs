defmodule Day6 do
  defp get_beating_times {time, distance} do
    1..(time - 1)
    |> Enum.map(& (time - &1) * &1)
    |> Enum.filter(& &1 > distance)
  end

  defp get_beating_times [time, distance] do
    get_beating_times {time, distance}
  end

  defp parse_line line do 
    line
    |> String.split(": ")
    |> Enum.at(1)
    |> String.trim
    |> String.split(" ")
    |> Enum.filter(& &1 !== "")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_input input do
    input
    |> Enum.map(&parse_line/1)
  end

  def parse_combined_input input do
    input
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(&Enum.at(&1, 1))
    |> Enum.map(&String.replace(&1, " ", ""))
    |> Enum.map(&String.to_integer/1)
  end

  def solution1 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> parse_input
      |> Enum.zip
      |> Enum.map(&get_beating_times/1)
      |> Enum.map(&length/1)
      |> Enum.product
      _ -> -1
    end
  end

  def solution2 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> parse_combined_input
      |> get_beating_times
      |> length
      _ -> -1
    end
  end
end

# IO.puts Day6.solution2 "./example.txt"
IO.puts Day6.solution2 "./input.txt"
