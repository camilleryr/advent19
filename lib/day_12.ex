defmodule Day12 do
  def test_input do
    """
    <x=-1, y=0, z=2>
    <x=2, y=-10, z=-7>
    <x=4, y=-8, z=8>
    <x=3, y=5, z=-1>
    """
  end

  def test_input_2 do
    """
    <x=-8, y=-10, z=0>
    <x=5, y=5, z=10>
    <x=2, y=-7, z=3>
    <x=9, y=-8, z=-3>
    """
  end

  def solve_part_1(input) do
    input
    |> parse()
    |> step(1000)
    |> calculate_final_energy()
  end

  def calculate_final_energy(moons) do
    moons
    |> Enum.map(fn {p, v} -> moon_energy(p) * moon_energy(v) end)
    |> Enum.sum()
  end

  def moon_energy(coods) do
    coods
    |> Enum.map(&abs/1)
    |> Enum.sum()
  end

  def step(moons, 0), do: moons
  def step(moons, steps), do: moons |> next() |> step(steps - 1)

  def solve_part_2(input) do
    input
    |> parse()
    |> find_orbital_period()
    |> IO.inspect()
    |> Enum.reduce(&lcm/2)
  end

  def lcm(m, n), do: div(m * n, gcd(m, n))

  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def find_orbital_period(
        moons,
        periods \\ [nil, nil, nil],
        history \\ [MapSet.new(), MapSet.new(), MapSet.new()],
        step \\ 0
      ) do
    moons
    |> to_coord_pairs()
    |> pair(periods, history)
    |> Enum.map(&update_period(&1, step))
    |> Enum.map(&update_history/1)
    |> depair()
    |> break_or_continue(moons, step + 1)
  end

  def break_or_continue({_, periods, history}, moons, next_step) do
    if Enum.all?(periods, & &1) do
      periods
    else
      moons
      |> next()
      |> find_orbital_period(periods, history, next_step)
    end
  end

  def to_coord_pairs(moons) do
    Enum.reduce(moons, [[], [], []], fn {[xp, yp, zp], [xv, yv, zv]}, [x_acc, y_acc, z_acc] ->
      [x_acc ++ [{xp, xv}], y_acc ++ [{yp, yv}], z_acc ++ [{zp, zv}]]
    end)
  end

  def update_period({position, nil, history} = arg, step) do
    if MapSet.member?(history, position) do
      {position, step, history}
    else
      arg
    end
  end

  def update_period(arg, _step), do: arg

  def update_history({position, period, history}) do
    {position, period, MapSet.put(history, position)}
  end

  def pair(a, b, c), do: Enum.zip([a, b, c])

  def depair(pairs) do
    Enum.reduce(pairs, {[], [], []}, fn {a, b, c}, {a_acc, b_acc, c_acc} ->
      {a_acc ++ [a], b_acc ++ [b], c_acc ++ [c]}
    end)
  end

  def next(moons) do
    for {position, velocity} = moon <- moons do
      new_velocity =
        moons
        |> Kernel.--([moon])
        |> Enum.map(fn {p, _v} ->
          position
          |> Enum.zip(p)
          |> Enum.map(fn pair ->
            case pair do
              {x, y} when x < y -> 1
              {x, y} when x == y -> 0
              {x, y} when x > y -> -1
            end
          end)
        end)
        |> Enum.reduce(velocity, fn p, acc ->
          acc
          |> Enum.zip(p)
          |> Enum.map(fn {x, y} -> x + y end)
        end)

      new_position =
        new_velocity
        |> Enum.zip(position)
        |> Enum.map(fn {x, y} -> x + y end)

      {new_position, new_velocity}
    end
  end

  def parse(input) do
    if String.starts_with?(input, "input") do
      File.stream!(input)
    else
      String.split(input, "\n", trim: true)
    end
    |> Enum.map(fn line ->
      ~r/<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/
      |> Regex.named_captures(line)
      |> to_shape()
    end)
  end

  def to_shape(%{"x" => x, "y" => y, "z" => z}),
    do: {[String.to_integer(x), String.to_integer(y), String.to_integer(z)], [0, 0, 0]}
end
