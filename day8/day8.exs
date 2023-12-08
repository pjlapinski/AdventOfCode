defmodule Math do
  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, Integer.gcd(a, b))
  def lcm(nums), do: nums |> Enum.reduce(&lcm(&1, &2))
end

defmodule Day8 do
  @start "AAA"
  @finish "ZZZ"

  @start_pt2 "A"
  @finish_pt2 "Z"

  defp select_move("L", [l, _]), do: l
  defp select_move("R", [_, r]), do: r

  defp parse_move move do
    [dest, rl] = move
    |> String.replace("(", "")
    |> String.replace(")", "")
    |> String.replace(" ", "")
    |> String.split("=")
    {dest, rl |> String.split(",")}
  end

  defp parse_input lines do
    [seq | moves] = lines
    moves = moves
    |> Enum.map(&parse_move/1)
    |> Map.new
    {seq, moves}
  end

  defp shift_seq seq do
    [fst | tail] = String.graphemes(seq)
    [fst | (tail |> Enum.reverse)] |> Enum.reverse |> Enum.join("")
  end

  defp eq_finish(val), do: val === @finish
  defp ends_with_finish(val), do: String.ends_with?(val, @finish_pt2)

  defp simulate({seq, moves}, start \\ @start, finish_fn \\ &eq_finish/1), do: simulate(seq, moves, start, finish_fn, 0)
  defp simulate seq, moves, curr, finish_fn, acc do
    next = select_move(String.at(seq, 0), moves[curr])
    if finish_fn.(next) do
      acc + 1
    else
      simulate(shift_seq(seq), moves, next, finish_fn, acc + 1)
    end
  end

  defp zip_with_starts {seq, moves} do
    starts = moves
    |> Map.keys
    |> Enum.filter(&String.ends_with?(&1, @start_pt2))
    {seq, moves, starts}
  end

  defp simulate_simultaneously {seq, moves, starts} do
    starts
    |> Enum.map(fn x -> simulate({seq, moves}, x, &ends_with_finish/1) end) 
    |> Math.lcm
  end

  def solution1 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> parse_input
      |> simulate
      _ -> -1
    end
  end

  def solution2 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> parse_input
      |> zip_with_starts
      |> simulate_simultaneously
      _ -> -1
    end
  end
end

# IO.puts Day8.solution2 "./example.txt"
# IO.puts Day8.solution1 "./example2.txt"
IO.puts Day8.solution2 "./input.txt"
