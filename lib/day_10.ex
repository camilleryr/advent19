defmodule Day10 do
  def test_input do
    """
    .#..##.###...#######
    ##.############..##.
    .#.######.########.#
    .###.#######.####.#.
    #####.##.#.##.###.##
    ..#####..#.#########
    ####################
    #.####....###.#.#.##
    ##.#################
    #####.##.###..####..
    ..######..##.#######
    ####.##.####...##..#
    .#####..#.######.###
    ##...#.##########...
    #.##########.#######
    .####.#.###.###.#.##
    ....##.##.###..#####
    .#.#.###########.###
    #.#.#.#####.####.###
    ###.##.####.##.#..##
    """
  end

  def solve_part_1(input) do
    astroids = input |> parse()

    astroids
    |> Enum.map(fn astroid -> astroid |> find_slopes(astroids) |> map_size() end)
    |> Enum.max()
  end

  def solve_part_2(input) do
    astroids = input |> parse()

    {slopes, base} =
      astroids
      |> Enum.map(&find_slopes(&1, astroids))
      |> Enum.zip(astroids)
      |> Enum.max_by(fn {slopes, _coord} -> map_size(slopes) end)

    slopes
    |> Map.keys()
    |> Enum.sort_by(&to_degree/1)
    |> Stream.cycle()
    |> Enum.reduce_while(
      {0, Map.new(slopes, fn {k, val} -> {k, Enum.sort_by(val, fn {x, y} -> x + y end)} end)},
      fn slope, {i, slopes} = acc ->
        case {Map.get(slopes, slope), i} do
          {nil, _} -> {:cont, acc}
          {_, 199} -> {:halt, slope}
          {[_val], _i} -> {:cont, {i + 1, Map.delete(slopes, slope)}}
          {[_val | rest], _i} -> {:cont, {i + 1, Map.put(slopes, slope, rest)}}
        end
      end
    )
    |> find_solution(base)
  end

  def find_solution({rel_x, rel_y}, {base_x, base_y}),
    do: floor((rel_x + base_x) * 100 + (rel_y + base_y))

  def to_degree({x, y}) do
    case :math.atan2(y, x) * 360 / (2 * :math.pi()) + 90 do
      x when x < 0 -> x + 360
      x -> x
    end
  end

  def find_slopes(astroid = {orig_x, orig_y}, astroids) do
    Enum.reduce(astroids, %{}, fn
      ^astroid, acc ->
        acc

      {abs_x, abs_y} = coord, acc ->
        slope = find_slope(astroid, coord)
        rel_coord = {orig_x - abs_x, orig_y - abs_y}
        Map.update(acc, slope, [rel_coord], &[rel_coord | &1])
    end)
  end

  def find_slope({x1, y1}, {x2, y2}) do
    x = x2 - x1
    y = y2 - y1
    gcd_ = gcd(y, x)

    {x / gcd_, y / gcd_}
  end

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def parse(input) do
    if String.starts_with?(input, "input") do
      File.stream!(input)
    else
      String.split(input, "\n", trim: true)
    end
    |> Stream.with_index()
    |> Enum.reduce([], fn {line, y_index}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", x_index}, acc -> [{x_index, y_index} | acc]
        _, acc -> acc
      end)
    end)
  end
end
