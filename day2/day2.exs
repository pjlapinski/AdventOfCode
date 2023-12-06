defmodule Day2 do
  defp parse_game txt do
    txt
    |> String.split(",")
    |> Enum.map(&Integer.parse/1)
  end

  defp parse_line line do
    {_, line} = String.split_at(line, 5)
    [num, line] = String.split(line, ": ")
    {num, _} = Integer.parse(num)
    games = line
    |> String.replace(" ", "")
    |> String.split(";")
    |> Enum.flat_map(&parse_game/1)
    {num, games}
  end

  defp game_possible {id, cubes} do
    limits = %{"red" => 12, "green" => 13, "blue" => 14}
    {id, Enum.all?(cubes, fn {num, cube} -> num <= limits[cube] end)}
  end

  defp count_min {_, cubes} do
    cubes
    |> Enum.reduce(
      %{"red" => 0, "green" => 0, "blue" => 0}, 
      fn ({n, color}, acc) -> 
        case acc[color] do
          x when x < n -> %{acc | color => n}
          _ -> acc
        end
      end)
    |> Map.values
  end

  def solution1 do
    {result, content} = File.read "./input.txt"
    case result do
      :ok -> content
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_line/1)
        |> Enum.map(&game_possible/1)
        |> Enum.filter(fn {_ , val} -> val end)
        |> Enum.map(fn {id, _} -> id end)
        |> Enum.sum
      _ -> -1
    end
  end

  def solution2 do
    {result, content} = File.read "./input.txt"
    case result do
      :ok -> content
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_line/1)
        |> Enum.map(&count_min/1)
        |> Enum.map(&Enum.product/1)
        |> Enum.sum
      _ -> -1
    end
  end
end

IO.puts Day2.solution1
IO.puts Day2.solution2
