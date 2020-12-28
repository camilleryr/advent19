defmodule Day5 do
  def solve_part_1(file_name) do
    file_name
    |> parse()
    |> Intcode.new(input: 1)
    |> Intcode.run_program()
    |> Intcode.get_output()
  end

  def solve_part_2(file_name) do
    file_name
    |> parse()
    |> Intcode.new(input: 5)
    |> Intcode.run_program()
    |> Intcode.get_output()
  end

  def parse(file_name) do
    file_name
    |> File.read!()
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def test(i) do
    """
    3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99
    """
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Intcode.new(input: i)
    |> Intcode.run_program()
  end
end
