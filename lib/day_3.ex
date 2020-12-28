defmodule Day3 do
  def test_input do
    """
    R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
    U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
    """
    |> String.split("\n", trim: true)
  end

  def solve_test_1, do: do_solve_part_1(test_input())
  def solve_part_1(file_path), do: file_path |> File.stream!() |> do_solve_part_1()

  def solve_test_2, do: do_solve_part_2(test_input())
  def solve_part_2(file_path), do: file_path |> File.stream!() |> do_solve_part_2()

  def do_solve_part_1(stream) do
    stream
    |> parse()
    |> Stream.map(&record_all_points/1)
    |> find_intersections()
    |> MapSet.to_list()
    |> Enum.reduce(nil, &find_closest_point/2)
  end

  def do_solve_part_2(stream) do
    paths = stream |> parse() |> Enum.map(&record_all_points/1)

    paths
    |> find_intersections()
    |> Enum.reduce(nil, &find_fewest_total_steps(&1, paths, &2))
  end

  def find_fewest_total_steps(intersection, paths, current_fewest) do
    paths
    |> Enum.map(fn path -> Enum.find_index(path, &match?(^intersection, &1)) end)
    |> Enum.sum()
    |> min(current_fewest)
  end

  def find_intersections(list) do
    list
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.delete({0, 0})
  end

  def find_closest_point({x, y}, small), do: min(small, abs(x) + abs(y))

  def record_all_points(movements) do
    movements
    |> Enum.reduce([{0, 0}], fn {direction, argument}, [current | _rest] = path ->
      new = for i <- argument..1, do: move(direction, current, i)

      Enum.concat(new, path)
    end)
    |> Enum.reverse()
  end

  def move("U", {x, y}, i), do: {x + i, y}
  def move("D", {x, y}, i), do: {x - i, y}
  def move("L", {x, y}, i), do: {x, y - i}
  def move("R", {x, y}, i), do: {x, y + i}

  def parse(stream) do
    stream
    |> Stream.map(fn line ->
      line
      |> String.split([",", "\n"], trim: true)
      |> Stream.map(fn <<code::binary-size(1), number::binary>> ->
        {code, String.to_integer(number)}
      end)
    end)
  end
end
