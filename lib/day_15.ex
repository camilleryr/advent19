defmodule Day15 do
  @north 1
  @south 2
  @west 3
  @east 4

  def solve_part_1(input) do
    origin = {0, 0}
    g = :digraph.new([:cyclic])
    :digraph.add_vertex(g, origin)

    i =
      input
      |> Intcode.parse()
      |> Intcode.new()

    [{origin, i}]
    |> do_solve_part_1(g)
    |> find_path(origin)
  end

  def find_path(graph, origin) do
    graph
    |> :digraph.get_short_path(origin, "o2_system")
    |> Enum.count()
    |> Kernel.-(1)
  end

  def solve_part_2(input) do
    origin = {0, 0}
    g = :digraph.new([:cyclic])
    :digraph.add_vertex(g, origin)

    i =
      input
      |> Intcode.parse()
      |> Intcode.new()

    [{origin, i}]
    |> do_solve_part_1(g)
    |> do_solve_part_2()
  end

  def do_solve_part_2(graph) do
    graph
    |> do_solve_part_2(["o2_system"], 0)
  end

  def do_solve_part_2(graph, verticies, step) do
    neighbors = verticies |> Enum.flat_map(&get_neighbors(&1, graph)) |> Enum.uniq()
    true = graph |> :digraph.del_vertices(verticies)

    case :digraph.no_vertices(graph) do
      0 -> step
      _ -> do_solve_part_2(graph, neighbors, step + 1)
    end
  end

  def get_neighbors(vertex, graph) do
    graph
    |> :digraph.in_neighbours(vertex)
    |> Enum.concat(:digraph.out_neighbours(graph, vertex))
  end

  def do_solve_part_1(positions, graph) do
    positions
    |> Enum.flat_map(&expand(&1, graph))
    |> Enum.uniq_by(fn {c, d, _} -> move(c, d) end)
    |> Enum.reduce_while([], fn {coord, dir, intcode}, acc ->
      next_coord = move(coord, dir)
      next = intcode |> Intcode.put_input(dir) |> Intcode.run_program()

      case Intcode.get_output(next) do
        0 ->
          {:cont, acc}

        other ->
          vertex =
            if other == 2 do
              "o2_system"
            else
              next_coord
            end

          :digraph.add_vertex(graph, vertex)
          :digraph.add_edge(graph, coord, vertex)
          {:cont, [{next_coord, next} | acc]}
      end
    end)
    |> case do
      [] -> graph
      list -> do_solve_part_1(list, graph)
    end
  end

  def expand({coord, intcode}, graph) do
    [@north, @east, @south, @west]
    |> Enum.reject(fn dir -> coord |> move(dir) |> visited?(graph) end)
    |> Enum.map(fn dir -> {coord, dir, intcode} end)
  end

  def move({x, y}, @north), do: {x + 1, y}
  def move({x, y}, @south), do: {x - 1, y}
  def move({x, y}, @east), do: {x, y + 1}
  def move({x, y}, @west), do: {x, y - 1}

  def visited?(position, graph), do: :digraph.vertex(graph, position)
end
