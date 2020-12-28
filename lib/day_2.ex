defmodule Day2 do
  def solve_part_1(file), do: file |> File.read!() |> do_solve(12, 2)

  def solve_part_2(file) do
    input = file |> File.read!()

    for noun <- 0..99, verb <- 0..99 do
      {noun, verb}
    end
    |> Enum.find_value(fn {noun, verb} ->
      case do_solve(input, noun, verb) do
        19_690_720 -> 100 * noun + verb
        _ -> nil
      end
    end)
  end

  def do_solve(input, noun, verb) do
    input
    |> parse()
    |> update_program(noun, verb)
    |> Intcode.run_program()
    |> Intcode.read_from_memory(0)
  end

  def update_program(intcode, noun, verb) do
    intcode
    |> Intcode.update_memory(1, noun)
    |> Intcode.update_memory(2, verb)
  end

  def parse(input) do
    input
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Intcode.new()
  end

  def test_1, do: "1,1,1,4,99,5,6,0,99" |> parse() |> Intcode.run_program()
end
