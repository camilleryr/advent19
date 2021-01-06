defmodule Day19 do
  def solve_part_1(input) do
    int = input |> Intcode.parse() |> Intcode.new()

    for(x <- 0..49, y <- 0..49, do: deploy(int, x, y))
    |> Enum.sum()
  end

  def solve_part_2(input) do
    int = input |> Intcode.parse() |> Intcode.new()

    find_points(int, 1523)
  end

  def find_points(intcode, x_index, history \\ %{}) do
    a = Task.async( fn -> Map.get_lazy(history, x_index, fn -> get_points(intcode, x_index) end) end)
    b = Task.async(fn -> get_points(intcode, x_index + 99) end)

    {_a_top, a_bottom} = a = Task.await(a)
    {b_top, _b_bottom} = b = Task.await(b)

    history = Map.put(history, x_index + 99, b)

    IO.inspect({x_index, a, b})

    if a_bottom - b_top == 99 do
      x_index * 10000 + b_top
    else
      find_points(intcode, x_index + 1, history)
    end
  end

  def get_points(intcode, x_index, y_index \\ 0, a \\ nil) do
    intcode
    |> deploy(x_index, y_index)
    |> case do
      0 when not is_nil(a) -> {a, y_index - 1}
      0 when is_nil(a) -> get_points(intcode, x_index, y_index + 1, a)
      1 when is_nil(a) -> get_points(intcode, x_index, y_index + 1, y_index)
      1 -> get_points(intcode, x_index, y_index + 1, a)
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
