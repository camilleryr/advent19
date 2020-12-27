defmodule Day1 do
  def solve_part_1(file), do: do_solve(file, &do_calculate_fuel/1)
  def solve_part_2(file), do: do_solve(file, &calculate_fuel/1)

  def do_solve(file, solver) do
    file
    |> File.stream!()
    |> Stream.map(fn line ->
      line
      |> parse_line()
      |> solver.()
    end)
    |> Enum.sum()
  end

  def calculate_fuel(mass) do
    mass
    |> Stream.iterate(&do_calculate_fuel/1)
    |> Stream.drop(1)
    |> Stream.take_while(&Kernel.>(&1, 0))
    |> Enum.sum()
  end

  def do_calculate_fuel(mass), do: div(mass, 3) - 2
  def parse_line(line), do: line |> Integer.parse() |> elem(0)
end
