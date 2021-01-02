defmodule Day13 do
  @block 2

  def solve_part_1(input) do
    input
    |> Intcode.parse()
    |> Intcode.new()
    |> Intcode.run_program()
    |> game_state()
    |> get_map()
    |> Enum.filter(fn {_key, tile_id} -> tile_id == @block end)
    |> Enum.count()
  end

  def solve_part_2(input) do
    input
    |> Intcode.parse()
    |> Intcode.new()
    |> Intcode.update_memory(0, 2)
    |> Intcode.run_program()
    |> play()
  end

  def play(intcode), do: play(Intcode.clear_output(intcode), game_state(intcode))

  def play(intcode, state) do
    {ball_x, _y} = get_ball(state)
    {paddle_x, _y} = get_paddle(state)

    input =
      cond do
        ball_x == paddle_x -> 0
        ball_x > paddle_x -> 1
        ball_x < paddle_x -> -1
      end

    intcode
    |> Intcode.put_input(input)
    |> Intcode.run_program()
    |> case do
      %{status: :halted} = i -> i |> game_state() |> get_score()
      %{status: :awaiting_input} = i -> play(Intcode.clear_output(i), game_state(i, state))
    end
  end

  def game_state(intcode, state \\ {%{}, 0, nil, nil}) do
    intcode
    |> Intcode.get_output(:all)
    |> Enum.reverse()
    |> to_state(state)
  end

  def to_state(output, acc)
  def to_state([], acc), do: acc

  def to_state([-1, 0, score | rest], {map, _score, ball, paddle}),
    do: to_state(rest, {map, score, ball, paddle})

  def to_state([x, y, id | rest], {map, score, ball, paddle}) do
    coord = {x, y}

    case id do
      3 -> to_state(rest, {Map.put(map, coord, id), score, ball, coord})
      4 -> to_state(rest, {Map.put(map, coord, id), score, coord, paddle})
      _other -> to_state(rest, {Map.put(map, coord, id), score, ball, paddle})
    end
  end

  def get_map({map, _score, _b, _p}), do: map
  def get_score({_map, score, _b, _p}), do: score
  def get_ball({_map, _score, b, _p}), do: b
  def get_paddle({_map, _score, _b, p}), do: p

  def print_game({map, score, _b, _p}) do
    # IEx.Helpers.clear()
    IO.inspect(score, label: score)

    map
    |> Enum.sort_by(fn {{_x, y}, _} -> y end)
    |> Enum.chunk_by(fn {{_x, y}, _} -> y end)
    |> Enum.map(fn line ->
      line
      |> Enum.sort_by(fn {{x, _y}, _} -> x end)
      |> Enum.map(fn {_coord, tile_id} ->
        case tile_id do
          0 -> " "
          1 -> "+"
          2 -> "#"
          3 -> "-"
          4 -> "o"
        end
      end)
      |> Enum.join()
      |> IO.puts()
    end)
  end
end
