defmodule Day7 do
  def solve_part_1(file_name), do: file_name |> read() |> do_solve_part_1()
  def test_part_1, do: test_input() |> parse_test() |> do_solve_part_1()

  def solve_part_2(file_name), do: file_name |> read() |> do_solve_part_2()
  def test_part_2, do: test_input_2() |> parse_test() |> do_solve_part_2()

  def do_solve_part_1(input) do
    starting_phases(0..4)
    |> Task.async_stream(fn phases ->
      Enum.reduce(phases, 0, fn phase, prev_output ->
        input
        |> Intcode.new(input: [phase, prev_output])
        |> Intcode.run_program()
        |> Intcode.get_output()
      end)
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  def do_solve_part_2(input) do
    starting_phases(5..9)
    |> Task.async_stream(fn phases ->
      phases
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {phase, index}, acc ->
        Map.put(acc, index, Intcode.new(input, input: phase))
      end)
      |> loop(0)
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  def loop(intcode_map, index_to_run) do
    prev_output = intcode_map |> Map.get(prev(index_to_run)) |> Intcode.get_output()

    intcode_map
    |> Map.get(index_to_run)
    |> Intcode.put_input(prev_output || 0)
    |> Intcode.run_program()
    |> case do
      %{status: :halted} = intcode when index_to_run == 4 ->
        Intcode.get_output(intcode)

      intcode ->
        intcode_map
        |> Map.put(index_to_run, intcode)
        |> loop(next(index_to_run))
    end
  end

  def prev(0), do: 4
  def prev(n), do: n - 1

  def next(4), do: 0
  def next(n), do: n + 1

  def starting_phases(range) do
    range = Enum.to_list(range)

    for a <- range,
        b <- range -- [a],
        c <- range -- [a, b],
        d <- range -- [a, b, c],
        e <- range -- [a, b, c, d] do
      [a, b, c, d, e]
    end
  end

  def read(file_name) do
    file_name
    |> File.read!()
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def test_input do
    "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
  end

  def test_input_2 do
    "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
  end

  def parse_test(input) do
    input
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end
