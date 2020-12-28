defmodule Day8 do
  def solve_part_1(file_name) do
    file_name
    |> parse()
    |> Enum.group_by(fn {{_x, _y, z}, _val} -> z end)
    |> Enum.map(fn {layer, cells} ->
      {layer, cells |> Enum.map(&elem(&1, 1)) |> Enum.frequencies()}
    end)
    |> Enum.min_by(fn {_layer, freq} ->
      Map.get(freq, "0")
    end)
    |> find_solution()
  end

  def find_solution({_layer, %{"1" => ones, "2" => twos}}), do: ones * twos

  def solve_part_2(file_name) do
    file_name
    |> parse()
    |> Enum.reject(fn {_cord, val} -> val == "2" end)
    |> Enum.group_by(fn {{x, y, _z}, _val} -> {x, y} end)
    |> Enum.map(fn {cord, cells} ->
      value =
        cells
        |> Enum.min_by(fn {{_x, _y, z}, _val} -> z end)
        |> elem(1)

      {cord, value}
    end)
    |> Enum.sort()
    |> Enum.map(&elem(&1, 1))
  end

  def parse(file_name) do
    file_name
    |> File.stream!([:trim_bom], 1)
    |> Stream.chunk_every(25)
    |> Stream.chunk_every(6)
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {layer, z_index}, acc ->
      layer
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {columns, x_index}, acc ->
        columns
        |> Enum.with_index()
        |> Map.new(fn {cell, y_index} -> {{x_index, y_index, z_index}, cell} end)
        |> Map.merge(acc)
      end)
    end)
  end
end

# 000000000000000000000000000
# 0   00    0    0 00 0   000
# 0 00 0000 0 0000 0 00 00 00
# 0 00 000 00   00  000   000
# 0   000 000 0000 0 00 00 00
# 0 0000 0000 0000 0 00 00 00
# 0 0000    0    0 00 0   000
# 000000000000000000000000000
