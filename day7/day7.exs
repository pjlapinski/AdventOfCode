defmodule Day7 do
  @joker "-"
  @joker_val 0

  defp figure_to_int(@joker), do: @joker_val
  defp figure_to_int("T"), do: 10
  defp figure_to_int("J"), do: 11
  defp figure_to_int("Q"), do: 12
  defp figure_to_int("K"), do: 13
  defp figure_to_int("A"), do: 14

  defp cmp_hands [h1 | t1], [h2 | t2] do
    h1 = if is_float(h1) do @joker_val else h1 end
    h2 = if is_float(h2) do @joker_val else h2 end
    cond do
      h1 === h2 -> cmp_hands(t1, t2)
      true -> h1 < h2
    end
  end

  defp cmp_scores x, y do
    {{t1, h1}, _} = x
    {{t2, h2}, _} = y
    cond do
      t1 !== t2 -> t1 > t2
      true -> cmp_hands(h1, h2)
    end
  end

  defp get_best_joker_swap cards do
    {c, _} = cards
    |> Enum.filter(& &1 !== @joker_val)
    |> Enum.frequencies
    |> Enum.to_list
    |> Enum.sort_by(& &1, fn {card1, freq1}, {card2, freq2} -> 
      cond do
        freq1 === freq2 -> card1 > card2
        true -> freq1 > freq2
      end
    end)
    |> hd
    c
  end

  defp do_best_joker_swap [@joker_val, @joker_val, @joker_val, @joker_val, @joker_val] do
    v = figure_to_int("A") + 0.1
    [v, v, v, v, v]
  end
  defp do_best_joker_swap hand do
    swp = get_best_joker_swap(hand) + 0.1
    hand |> Enum.map(& if &1 === @joker_val do swp else &1 end)
  end

  defp get_hand_type hand do
    case hand do
      [x,x,x,x,x] -> 0
      [_,x,x,x,x] -> 1
      [x,x,x,x,_] -> 1
      [y,y,x,x,x] -> 2
      [x,x,x,y,y] -> 2
      [_,_,x,x,x] -> 3
      [x,x,x,_,_] -> 3
      [_,x,x,x,_] -> 3
      [x,x,y,y,_] -> 4
      [x,x,_,y,y] -> 4
      [_,x,x,y,y] -> 4
      [x,x,_,_,_] -> 5
      [_,x,x,_,_] -> 5
      [_,_,x,x,_] -> 5
      [_,_,_,x,x] -> 5
      _ -> 6
    end
  end

  defp zip_with_type {hand, bid} do
    h = hand
    |> Enum.map(&trunc/1)
    |> Enum.sort
    {{get_hand_type(h), hand}, bid}
  end

  defp parse_hand text do
    hand = text
    |> String.graphemes
    |> Enum.map(fn char -> 
      case Integer.parse(char) do
        :error -> figure_to_int(char)
        {i, _} -> i
      end
    end)
    hand
  end

  defp parse_line [hand, bid] do
    {hand |> parse_hand, String.to_integer(bid)}
  end

  def solution1 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(&parse_line/1)
      |> Enum.map(&zip_with_type/1)
      |> Enum.sort_by(& &1, &cmp_scores/2)
      |> Enum.map(fn {_, x} -> x end)
      |> Enum.with_index(1)
      |> Enum.map(fn {x, y} -> x * y end)
      |> Enum.sum
      _ -> -1
    end
  end

  def solution2 file do
    {result, content} = File.read file
    case result do
      :ok -> content
      |> String.replace("J", "-")
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(&parse_line/1)
      |> Enum.map(fn {hand, bid} -> {do_best_joker_swap(hand), bid} end)
      |> Enum.map(&zip_with_type/1)
      |> Enum.sort_by(& &1, &cmp_scores/2)
      |> Enum.map(fn {_, x} -> x end)
      |> Enum.with_index(1)
      |> Enum.map(fn {x, y} -> x * y end)
      |> Enum.sum
      _ -> -1
    end
  end
end

# IO.puts Day7.solution2 "./example.txt"
IO.puts Day7.solution2 "./input.txt"
