defmodule Day2 do
  def solve_part_1(file), do: do_solve(file, 12, 2)

  def solve_part_2(file) do
    for noun <- 0..99, verb <- 0..99 do
      {noun, verb}
    end
    |> Enum.find_value(fn {noun, verb} ->
      case do_solve(file, noun, verb) do
        19_690_720 -> 100 * noun + verb
        _ -> nil
      end
    end)
  end

  def do_solve(input, noun, verb) do
    input
    |> Intcode.parse()
    |> Intcode.new()
    |> update_program(noun, verb)
    |> Intcode.run_program()
    |> Intcode.read_from_memory(0)
  end

  def update_program(intcode, noun, verb) do
    intcode
    |> Intcode.update_memory(1, noun)
    |> Intcode.update_memory(2, verb)
  end
end
