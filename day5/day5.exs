defmodule Day5 do
  defp nums_to_ints line do
    line
    |> String.trim
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_seeds seeds do
    seeds
    |> String.split(": ")
    |> Enum.at(1)
    |> nums_to_ints
  end

  defp parse_map map do
    map
    |> String.split("\n")
    |> tl
    |> Enum.map(&nums_to_ints/1)
  end

  defp parse_input [seeds | maps] do
    seeds = parse_seeds seeds
    maps = maps
    |> Enum.map(&String.trim/1)
    |> Enum.map(&parse_map/1)
    {seeds, maps}
  end

  defp value_through_range value, [dest_start, source_start, len] do
    cond do
      value >= source_start && value < (source_start + len) -> dest_start + (value - source_start)
      true -> value
    end
  end

  defp value_through_map value, map do
    case map |> Enum.map(&value_through_range(value, &1)) |> Enum.find(& &1 !== value) do
      nil -> value
      x -> x
    end
  end

  defp seeds_to_locations {seeds, maps} do
    seeds
    |> Enum.map(fn seed -> Enum.reduce(maps, seed, &(value_through_map(&2, &1))) end)
  end

  @chunk_size 1_000_000

  defp seed_ranges_to_locations {seeds, maps} do
    seeds 
    |> Enum.chunk_every(2)
    |> Enum.flat_map(fn [min, max] -> 
      max = min + max - 1
      chunks = round((max - min) / @chunk_size)
      for i <- 0..(chunks - 1) do
        m = min + i * @chunk_size
        n = min + (i + 1) * @chunk_size
        (if n > max do max else m end)..(if n > max do max else n end)
      end
    end)
    |> Task.async_stream(&seeds_to_locations({&1, maps}), max_concurrency: 16, timeout: :infinity, ordered: false)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.map(&Enum.min/1)
  end

  def solution1 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n\n", trim: true)
      |> parse_input
      |> seeds_to_locations
      |> Enum.min
      _ -> -1
    end
  end

  def solution2 file do
    {result, content} = File.read file
    case result do
    :ok -> content
      |> String.split("\n\n", trim: true)
      |> parse_input
      |> seed_ranges_to_locations
      |> Enum.min
      _ -> -1
    end
  end
end

# IO.puts Day5.solution2 "./example.txt"
IO.puts Day5.solution2 "./input.txt"
