defmodule Day14 do
  import Advent19

  @doc ~S"""
  # Example
    iex> solve_part_1(test_input(0))
    31

    iex> solve_part_1(test_input(1))
    165

    iex> solve_part_1(test_input(2))
    13312

    iex> solve_part_1(test_input(3))
    180697

    iex> solve_part_1(test_input(4))
    2210736
  """
  def solve_part_1(input) do
    input
    |> get_input()
    |> parse()
    |> find_cost()
  end

  @doc ~S"""
  # Example
    iex> solve_part_2(test_input(2))
    82892753

    iex> solve_part_2(test_input(3))
    5586022

    iex> solve_part_2(test_input(4))
    460664
  """
  def solve_part_2(input) do
    prices = input |> get_input() |> parse()

    Stream.iterate(1, &(&1 * 10))
    |> Stream.drop_while(fn n ->
      ore = find_cost(prices, n) |> IO.inspect(label: n)
      ore < 1_000_000_000_000
    end)
    |> Enum.take(1)
    |> (fn [x] -> binary_search(prices, div(x, 10), x) end).()
  end

  def binary_search(prices, start_n, end_n) do
    half = div(end_n - start_n, 2) + start_n

    case find_cost(prices, half) |> IO.inspect(label: half) do
      res when res > 1_000_000_000_000 ->
        if find_cost(prices, half - 1) < 1_000_000_000_000 do
          half - 1
        else
          binary_search(prices, start_n, half)
        end

      _ ->
        binary_search(prices, half, end_n)
    end
  end

  def find_cost(prices, fuel \\ 1), do: find_cost(%{:FUEL => fuel}, prices, 0, operation: :floor)

  def find_cost(have, prices, x, opts) do
    # if(x == 10, do: throw(:error))

    reduced = reduce(have, prices, opts)

    cond do
      reduction_complete?(reduced) -> reduced[:ORE]
      reduced == have -> find_cost(have, prices, x + 1, operation: :ceil)
      true -> find_cost(reduced, prices, x + 1, operation: :floor)
    end
  end

  def reduce(have, prices, operation: operation) do
    {to_reduce, reduced} = Enum.split_with(have, fn {el, _am} -> el != :ORE end)

    for {to_reduce_element, to_reduce_amount} <- to_reduce, reduce: Map.new(reduced) do
      reduced ->
        if to_reduce_amount > 0 do
          %{ingredients: ingredients, output: output} = prices[to_reduce_element]
          ingredient_groups = apply(Kernel, operation, [to_reduce_amount / output])

          reduced_ingredients =
            if ingredient_groups > 0 do
              Enum.map(ingredients, fn {n, e} -> {e, n * ingredient_groups} end)
            end
            |> List.wrap()

          remaining_to_reduce_elements = [
            {to_reduce_element, to_reduce_amount - ingredient_groups * output}
          ]

          (reduced_ingredients ++ remaining_to_reduce_elements)
          |> Enum.reduce(reduced, fn {e, n}, acc -> Map.update(acc, e, n, &(&1 + n)) end)
        else
          Map.update(reduced, to_reduce_element, to_reduce_amount, &(&1 + to_reduce_amount))
        end
    end
  end

  def reduction_complete?(have) do
    [:ORE] == Enum.reduce(have, [], fn {k, v}, acc -> if v > 0, do: [k | acc], else: acc end)
  end

  def parse(string) do
    string
    |> Advent19.get_input()
    |> String.split("\n", trim: true)
    |> Map.new(fn line ->
      [{num_out, element} | input] =
        line
        |> String.split([" ", ",", "=>"], trim: true)
        |> Enum.chunk_every(2)
        |> Enum.map(fn [int, element] -> {String.to_integer(int), String.to_atom(element)} end)
        |> Enum.reverse()

      {element, %{output: num_out, ingredients: input}}
    end)
  end

  def test_input(0) do
    """
    10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL
    """
  end

  def test_input(1) do
    """
    9 ORE => 2 A
    8 ORE => 3 B
    7 ORE => 5 C
    3 A, 4 B => 1 AB
    5 B, 7 C => 1 BC
    4 C, 1 A => 1 CA
    2 AB, 3 BC, 4 CA => 1 FUEL
    """
  end

  def test_input(2) do
    """
    157 ORE => 5 NZVS
    165 ORE => 6 DCFZ
    44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
    12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
    179 ORE => 7 PSHF
    177 ORE => 5 HKGWZ
    7 DCFZ, 7 PSHF => 2 XJWVT
    165 ORE => 2 GPVTF
    3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
    """
  end

  def test_input(3) do
    """
    2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
    17 NVRVD, 3 JNWZP => 8 VPVL
    53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
    22 VJHF, 37 MNCFX => 5 FWMGM
    139 ORE => 4 NVRVD
    144 ORE => 7 JNWZP
    5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
    5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
    145 ORE => 6 MNCFX
    1 NVRVD => 8 CXFTF
    1 VJHF, 6 MNCFX => 4 RFSQX
    176 ORE => 6 VJHF
    """
  end

  def test_input(4) do
    """
    171 ORE => 8 CNZTR
    7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
    114 ORE => 4 BHXH
    14 VRPVC => 6 BMBT
    6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
    6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
    15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
    13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
    5 BMBT => 4 WPTQ
    189 ORE => 9 KTJDG
    1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
    12 VRPVC, 27 CNZTR => 2 XDBXC
    15 KTJDG, 12 BHXH => 5 XCVML
    3 BHXH, 2 VRPVC => 7 MZWV
    121 ORE => 7 VRPVC
    7 XCVML => 6 RJRHP
    5 BHXH, 4 VRPVC => 5 LTCX
    """
  end
end

11_422_404_519
27302
11_422_725_987
1_000_000_000_000
27303
