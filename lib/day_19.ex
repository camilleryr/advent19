defmodule Day19 do
  def solve_part_1(input) do
    int = input |> Intcode.parse() |> Intcode.new()

    for(x <- 0..49, y <- 0..49, do: deploy(int, x, y))
    |> Enum.sum()
  end

  def solve_part_2(input) do
    int = input |> Intcode.parse() |> Intcode.new()
    {a_25, b_25} = get_points(int, 25)
    {a_50, b_50} = get_points(int, 50)

    a_slope = 25 / (a_50 - a_25)
    b_slope = 25 / (b_50 - b_25)

    {a_slope, b_slope}
  end

  def get_points(intcode, y_index, x_index \\ 0, a \\ nil) do
    intcode
    |> deploy(x_index, y_index)
    |> case do
      0 when not is_nil(a) -> {a, x_index - 1}
      0 when is_nil(a) -> get_points(intcode, y_index, x_index + 1, a)
      1 when is_nil(a) -> get_points(intcode, y_index, x_index + 1, x_index)
      1 -> get_points(intcode, y_index, x_index + 1, a)
    end
  end

  def deploy(intcode, x, y) do
    intcode
    |> Intcode.put_input(x)
    |> Intcode.run_program()
    |> Intcode.put_input(y)
    |> Intcode.run_program()
    |> Intcode.get_output()
  end
end
