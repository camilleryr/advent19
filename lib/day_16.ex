defmodule Day16 do
  @pattern [0, 1, 0, -1]

  def test_input do
    """
    03036732577212944063491565474664
    """
  end

  def solve_part_1(input) do
    input = input |> parse()
    pattern = gen_pattern(input)

    input
    |> phase(pattern, 100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def solve_part_2(input) do
    input = input |> parse()
    offset = input |> Enum.take(7) |> Enum.join() |> String.to_integer()
    input = input |> Stream.cycle() |> Enum.take(length(input) * 10000) |> Enum.drop(offset)

    input
    |> phase_2(100)
    |> Enum.take(8)
    |> Enum.join()
  end

  def gen_pattern(input) do
    l = length(input)

    1..l
    |> Enum.map(fn i ->
      @pattern
      |> Stream.flat_map(fn n ->
        n
        |> List.wrap()
        |> Stream.cycle()
        |> Enum.take(i)
      end)
      |> Stream.cycle()
      |> Stream.drop(1)
      |> Enum.take(l)
    end)
  end

  def phase(input, _patterns, 0), do: input

  def phase(input, patterns, gen) do
    patterns
    |> Enum.map(fn pattern ->
      pattern
      |> Enum.zip(input)
      |> Enum.map(fn {a, b} -> a * b end)
      |> Enum.sum()
      |> rem(10)
      |> abs()
    end)
    |> IO.inspect()
    |> phase(patterns, gen - 1)
  end

  def phase_2(input, 0), do: input

  def phase_2(input, gen) do
    input
    |> Enum.reverse()
    |> Enum.reduce({[], 0}, fn n, {res, acc} ->
      acc = n + acc
      {[rem(acc, 10) | res], acc}
    end)
    |> elem(0)
    |> phase_2(gen - 1)
  end

  def parse(input) do
    if String.starts_with?(input, "input") do
      File.read!(input)
    else
      input
    end
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end
end
