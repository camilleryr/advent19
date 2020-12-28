defmodule Day6 do
  def solve_part_1(file_name), do: file_name |> read() |> do_solve_part_1()
  def test_part_1, do: test_input() |> parse_test() |> do_solve_part_1()

  def solve_part_2(file_name), do: file_name |> read() |> do_solve_part_2()
  def test_part_2, do: test_input_2() |> parse_test() |> do_solve_part_2()

  def do_solve_part_1(input) do
    graph = :digraph.new([:acyclic])

    input
    |> to_graph(graph)
    |> :digraph.vertices()
    |> Enum.map(&:digraph.get_path(graph, "COM", &1))
    |> Enum.reduce(0, fn
      false, acc -> acc
      path, acc -> acc + (length(path) - 1)
    end)
  end

  def do_solve_part_2(input) do
    graph = :digraph.new([:cyclic])

    input
    |> to_graph(graph)
    |> :digraph.get_short_path("YOU", "SAN")
    |> length()
    |> Kernel.-(3)
  end

  def to_graph(input, graph) do
    Enum.reduce(input, graph, fn {obj_1, obj_2}, graph ->
      v1 = :digraph.add_vertex(graph, obj_1)
      v2 = :digraph.add_vertex(graph, obj_2)

      _edge = :digraph.add_edge(graph, v1, v2)
      _edge = :digraph.add_edge(graph, v2, v1)

      graph
    end)
  end

  def read(file_name) do
    file_name
    |> File.stream!()
    |> Stream.map(fn <<obj_1::binary-size(3), ")", obj_2::binary-size(3), _rest>> ->
      {obj_1, obj_2}
    end)
  end

  def test_input do
    """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """
  end

  def test_input_2 do
    """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    K)YOU
    I)SAN
    """
  end

  def parse_test(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(")", trim: true)
      |> List.to_tuple()
    end)
  end
end
