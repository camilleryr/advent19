defmodule Day20 do
  def test_input do
    """
                       A
                       A
      #################.#############
      #.#...#...................#.#.#
      #.#.#.###.###.###.#########.#.#
      #.#.#.......#...#.....#.#.#...#
      #.#########.###.#####.#.#.###.#
      #.............#.#.....#.......#
      ###.###########.###.#####.#.#.#
      #.....#        A   C    #.#.#.#
      #######        S   P    #####.#
      #.#...#                 #......VT
      #.#.#.#                 #.#####
      #...#.#               YN....#.#
      #.###.#                 #####.#
    DI....#.#                 #.....#
      #####.#                 #.###.#
    ZZ......#               QG....#..AS
      ###.###                 #######
    JO..#.#.#                 #.....#
      #.#.#.#                 ###.#.#
      #...#..DI             BU....#..LF
      #####.#                 #.#####
    YN......#               VT..#....QG
      #.###.#                 #.###.#
      #.#...#                 #.....#
      ###.###    J L     J    #.#.###
      #.....#    O F     P    #.#...#
      #.###.#####.#.#####.#####.###.#
      #...#.#.#...#.....#.....#.#...#
      #.#####.###.###.#.#.#########.#
      #...#.#.....#...#.#.#.#.....#.#
      #.###.#####.###.###.#.#.#######
      #.#.........#...#.............#
      #########.###.###.#############
               B   J   C
               U   P   P
    """
  end

  def solve_part_1(input) do
    map = parse(input)

    starting_portal =
      map
      |> Enum.find_value(fn
        {key, {:portal, "AA"}} ->
          key

        _ ->
          false
      end)

    start =
      starting_portal
      |> neighbors()
      |> Enum.find_value(fn key ->
        if Map.get(map, key) do
          key
        else
          false
        end
      end)

    start
    |> List.wrap()
    |> step(Map.delete(map, starting_portal))
  end

  def step(positions, map, history \\ nil, step \\ 0) do
    history =
      if is_nil(history) do
        MapSet.new(positions)
      else
        history
      end

    next =
      map
      |> Map.take(
        positions
        |> Enum.flat_map(&neighbors/1)
        |> Enum.uniq()
      )
      |> Enum.filter(& &1)
      |> Enum.map(fn
        {key, :path} ->
          key

        {key, {:portal, id}} ->
          Enum.find_value(map, :complete, fn
            {k, {:portal, ^id}} when k != key ->
              k
              |> neighbors()
              |> Enum.find_value(fn key ->
                if Map.get(map, key) do
                  key
                else
                  false
                end
              end)

            _ ->
              false
          end)
      end)

    if Enum.member?(next, :complete) do
      step
    else
      next = next |> Enum.reject(&MapSet.member?(history, &1))
      n_h = next |> MapSet.new() |> MapSet.union(history)
      step(next, map, n_h, step + 1)
    end
  end

  def neighbors({x, y}) do
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
  end

  def parse(input) do
    if String.starts_with?(input, "input") do
      File.stream!(input)
    else
      String.split(input, "\n", trim: true)
    end
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, y_index}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {cell, x_index}, acc ->
        case cell do
          cell when cell in ["#", " "] -> acc
          "." -> Map.put(acc, {x_index, y_index}, :path)
          portal_id -> Map.put(acc, {x_index, y_index}, portal_id)
        end
      end)
    end)
    |> create_portals()
  end

  def create_portals(map) do
    map
    |> Enum.flat_map(fn
      {_key, :path} = kvp ->
        [kvp]

      {{x, y} = key, id} ->
        left = Map.get(map, {x - 1, y})
        right = Map.get(map, {x + 1, y})
        up = Map.get(map, {x, y - 1})
        down = Map.get(map, {x, y + 1})

        cond do
          is_binary(left) and right == :path -> [{key, {:portal, left <> id}}]
          is_binary(right) and left == :path -> [{key, {:portal, id <> right}}]
          is_binary(up) and down == :path -> [{key, {:portal, up <> id}}]
          is_binary(down) and up == :path -> [{key, {:portal, id <> down}}]
          true -> []
        end
    end)
    |> Map.new()
  end
end
