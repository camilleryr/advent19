defmodule Day2 do
  @starting_position 0

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
    |> run_program(@starting_position)
    |> read(0)
  end

  def update_program(memory, noun, verb) do
    memory
    |> update(1, noun)
    |> update(2, verb)
  end

  def run_program(memory, position) do
    case read(memory, position) do
      99 ->
        memory

      op_code when op_code in [1, 2] ->
        [p1, p2, d] = read_next(memory, position, 3)

        memory
        |> update(d, operate(op_code, read(memory, p1), read(memory, p2)))
        |> run_program(position + 4)
    end
  end

  def operate(1, x, y), do: x + y
  def operate(2, x, y), do: x * y

  def parse(input) do
    input
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
    |> :array.from_list()
  end

  def update(memory, position, value), do: :array.set(position, value, memory)
  def read(memory, position), do: :array.get(position, memory)
  def read_next(memory, position, n), do: for(i <- 1..n, do: read(memory, position + i))

  def test_1, do: "1,1,1,4,99,5,6,0,99" |> parse() |> run_program(0)
end
