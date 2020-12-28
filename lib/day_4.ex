defmodule Day4 do
  def input, do: 152_085..670_283

  def solve_part_1(_file_name), do: solve([&includes_dupes/1, &sorted/1])
  def solve_part_2(_file_name), do: solve([&exactly_two/1, &sorted/1])

  def solve(validators) do
    input()
    |> Enum.filter(fn int_password ->
      int_password
      |> to_string()
      |> String.graphemes()
      |> validate(validators)
    end)
    |> Enum.count()
  end

  def validate(charlist, validators), do: Enum.all?(validators, & &1.(charlist))

  def includes_dupes(charlist), do: charlist != Enum.dedup(charlist)
  def sorted(charlist), do: charlist == Enum.sort(charlist)

  def exactly_two(charlist),
    do: charlist |> Enum.chunk_by(& &1) |> Enum.any?(&(Enum.count(&1) == 2))
end
