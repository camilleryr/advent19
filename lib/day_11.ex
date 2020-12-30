defmodule Day11 do
  defmodule PainterBot do
    defstruct [:brain, :position, :direction, :hull]

    @black 0
    @white 1

    @directions %{
      north: {:west, :east},
      east: {:north, :south},
      south: {:east, :west},
      west: {:south, :north}
    }

    def white, do: @white

    def instal_brain(intcode, opts \\ []) do
      struct(__MODULE__,
        brain: intcode,
        position: {0, 0},
        direction: :north,
        hull: Keyword.get(opts, :hull, %{})
      )
    end

    def paint(bot) do
      bot
      |> update_brain(&Intcode.put_input(&1, Map.get(bot.hull, bot.position, @black)))
      |> update_brain(&Intcode.run_program/1)
      |> paint_hull()
      |> move()
      |> case do
        %{brain: %{status: :halted}} = bot -> bot
        %{brain: %{status: :awaiting_input}} = bot -> paint(bot)
      end
    end

    def pretty_print(%{hull: hull}) do
      [x_range, y_range] = get_boundries(hull)

      Enum.map(x_range, fn x ->
        y_range
        |> Enum.map(fn y ->
          case Map.get(hull, {x, y}, @black) do
            @black -> " "
            @white -> "X"
          end
        end)
        |> Enum.join()
        |> IO.puts()
      end)

      :ok
    end

    def get_boundries(hull) do
      hull
      |> Map.keys()
      |> Enum.reduce([[], []], fn {x, y}, [xs, ys] ->
        [[x | xs], [y | ys]]
      end)
      |> Enum.map(fn points ->
        {min, max} = Enum.min_max(points)
        (min - 1)..(max + 1)
      end)
    end

    def update_brain(bot, fun), do: Map.update!(bot, :brain, fun)

    def paint_hull(bot) do
      [_, color] = Intcode.get_output(bot.brain, 2)
      Map.update!(bot, :hull, &Map.put(&1, bot.position, color))
    end

    def move(bot) do
      bot.brain
      |> Intcode.get_output()
      |> turn(bot)
      |> step_forward()
    end

    def turn(command, bot) do
      Map.put(bot, :direction, @directions |> Map.get(bot.direction) |> elem(command))
    end

    def step_forward(%{position: {x, y}, direction: :north} = bot),
      do: %{bot | position: {x, y + 1}}

    def step_forward(%{position: {x, y}, direction: :east} = bot),
      do: %{bot | position: {x + 1, y}}

    def step_forward(%{position: {x, y}, direction: :south} = bot),
      do: %{bot | position: {x, y - 1}}

    def step_forward(%{position: {x, y}, direction: :west} = bot),
      do: %{bot | position: {x - 1, y}}
  end

  def solve_part_1(file_name) do
    file_name
    |> Intcode.parse()
    |> Intcode.new()
    |> PainterBot.instal_brain()
    |> PainterBot.paint()
    |> Map.get(:hull)
    |> map_size()
  end

  def solve_part_2(file_name) do
    file_name
    |> Intcode.parse()
    |> Intcode.new()
    |> PainterBot.instal_brain(hull: %{{0, 0} => PainterBot.white()})
    |> PainterBot.paint()
    |> PainterBot.pretty_print()
  end
end

#   XXXX
#  X    X
#  X X  X
#  XXX X

#  XXXXX
#    X  X
#    X  X
#  XXXXX

#  XXXXXX
#    X  X
#   XX  X
#  X  XX

#  XXXXXX
#    X  X
#    X  X
#     XX

#  XXXXXX
#     X
#   XX X
#  X    X

#  XX   X
#  X X  X
#  X  X X
#  X   XX

#   XXXXX
#  X
#  X
#   XXXXX

#  XXXXXX
#  X
#  X
#  X

