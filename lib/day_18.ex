defmodule Day18 do
  defstruct [:coord, :keys, :doors, :self_history]

  def test_input do
    """
    ########################
    #...............b.C.D.f#
    #.######################
    #.....@.a.B.c.d.A.e.F.g#
    ########################
    """
  end

  def test_input_2 do
    """
    #################
    #i.G..c...e..H.p#
    ########.########
    #j.A..b...f..D.o#
    ########@########
    #k.E..a...g..B.n#
    ########.########
    #l.F..d...h..C.m#
    #################
    """
  end

  def test_input_3 do
    """
    ########################
    #@..............ac.GI.b#
    ###d#e#f################
    ###A#B#C################
    ###g#h#i################
    ########################
    """
  end

  def test_input_4 do
    """
    #############
    #g#f.D#..h#l#
    #F###e#E###.#
    #dCba.#.BcIJ#
    ######@######
    #nK.L.#.G...#
    #M###N#H###.#
    #o#m..#i#jk.#
    #############
    """
  end

  def solve_part_1(input) do
    map = input |> parse()
    keys = get_key_set(map)
    starting_point = map |> get_origin() |> new() |> List.wrap()

    starting_point
    |> find_keys(map, keys, MapSet.new(starting_point), 1)
    |> elem(1)
  end

  def find_keys(positions, map, keys, history, steps) do
    IO.inspect(steps)
    # if steps > 200 or enum.empty?(positions), do: throw(:error)

    {next, next_history} = step(positions, map, history)

    next
    |> Enum.find_value(fn %{keys: next_keys} = p ->
      if MapSet.equal?(next_keys, keys) do
        p
      end
    end)
    |> case do
      %{} = p -> {p, steps}
      _ -> find_keys(next, map, keys, next_history, steps + 1)
    end
  end

  def step(positions, map, history) do
    positions
    |> Enum.reduce({[], history}, fn position, {acc, history} ->
      {n, h} =
        position.coord
        |> neighbors()
        |> Enum.map(&new(&1, position))
        |> Enum.reduce({[], history}, fn %{coord: c, keys: k} = p, {inner_acc, history} = ia ->
          current = Map.get(map, c)

          if is_nil(current) or MapSet.member?(history, p) do
            ia
          else
            case current do
              {:open, _} ->
                {[p | inner_acc], MapSet.put(history, p)}

              {:key, key} ->
                new_keys = MapSet.put(k, key)

                {[%{p | keys: new_keys} | inner_acc], MapSet.put(history, p)}

              {:door, door} ->
                if MapSet.member?(k, String.downcase(door)) do
                  {[p | inner_acc], MapSet.put(history, p)}
                else
                  ia
                end
            end
          end
        end)

      {n ++ acc, h}
    end)
  end

  def get_origin(map) do
    Enum.find_value(map, fn
      {coord, {:open, "@"}} -> coord
      _ -> false
    end)
  end

  def get_key_set(map) do
    Enum.reduce(map, MapSet.new(), fn
      {_coord, {:key, key}}, keys -> MapSet.put(keys, key)
      _, keys -> keys
    end)
  end

  def split({x, y} = origin, map) do
    [
      {{x - 1, y - 1}, submap(map, origin, &Kernel.</2, &Kernel.</2)},
      {{x - 1, y + 1}, submap(map, origin, &Kernel.</2, &Kernel.>/2)},
      {{x + 1, y - 1}, submap(map, origin, &Kernel.>/2, &Kernel.</2)},
      {{x + 1, y + 1}, submap(map, origin, &Kernel.>/2, &Kernel.>/2)}
    ]
    |> Enum.unzip()
  end

  def submap(map, {x, y}, x_fun, y_fun) do
    map
    |> Enum.filter(fn {{a, b}, _} -> x_fun.(a, x) and y_fun.(b, y) end)
    |> Map.new()
  end

  def neighbors({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  def new(coord, existing \\ %{}) do
    %__MODULE__{
      coord: coord,
      keys: Map.get(existing, :keys, MapSet.new()),
      doors: Map.get(existing, :doors, MapSet.new()),
      self_history: Map.get(existing, :self_history, MapSet.new())
    }
  end

  def parse(input) do
    if String.starts_with?(input, "input") do
      File.stream!(input)
    else
      String.split(input, "\n")
    end
    |> Stream.with_index()
    |> Enum.reduce(%{}, fn {line, y_index}, map ->
      line
      |> String.graphemes()
      |> Stream.with_index()
      |> Stream.reject(fn {x, _} -> x == "#" end)
      |> Enum.reduce(map, fn
        {cell, x_index}, map when cell in [".", "@"] ->
          Map.put(map, {x_index, y_index}, {:open, cell})

        {cell, x_index}, map ->
          if String.upcase(cell) == cell do
            Map.put(map, {x_index, y_index}, {:door, cell})
          else
            Map.put(map, {x_index, y_index}, {:key, cell})
          end
      end)
    end)
  end
end
