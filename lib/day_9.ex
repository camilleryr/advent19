defmodule Day9 do
  def solve_part_1(file_name) do
    file_name
    |> Intcode.parse()
    |> Intcode.new(input: 1)
    |> Intcode.run_program()
    |> Intcode.get_output()
  end

  def solve_part_2(file_name) do
    file_name
    |> Intcode.parse()
    |> Intcode.new(input: 2)
    |> Intcode.run_program()
    |> Intcode.get_output()
  end
end
