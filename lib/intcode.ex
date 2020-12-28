defmodule Intcode do
  # memory, adress, instruction (with paramaters), pointer
  # input, output, operation

  defstruct [
    :memory,
    :pointer_adress,
    :input,
    :output,
    :operation_index,
    :op_code,
    :paramaters,
    :paramater_modes,
    :evaluated_params,
    :status
  ]

  def new(memory, opts \\ []) do
    %__MODULE__{
      memory: :array.from_list(memory),
      pointer_adress: Keyword.get(opts, :pointer_adress, 0),
      input: Keyword.get(opts, :input, []) |> List.wrap(),
      operation_index: 0,
      status: :new
    }
  end

  def put_input(intcode, value) do
    Map.update!(intcode, :input, fn existing -> existing ++ [value] end)
  end

  def update_memory(intcode, position, value) do
    %{intcode | memory: update(intcode.memory, position, value)}
  end

  def read_from_memory(intcode, position) do
    read(intcode.memory, position)
  end

  def get_output(intcode), do: intcode.output

  def run_program(%__MODULE__{} = intcode) do
    intcode
    |> read_opcode()
    |> read_paramaters()
    |> evaluate_params()
    |> execute_instruction()
  end

  def execute_instruction(
        %{op_code: 1, evaluated_params: [x, y | _], paramaters: [_x, _y, dest]} = intcode
      ) do
    intcode
    |> update_memory(dest, x + y)
    |> next()
  end

  def execute_instruction(
        %{op_code: 2, evaluated_params: [x, y | _], paramaters: [_x, _y, dest]} = intcode
      ) do
    intcode
    |> update_memory(dest, x * y)
    |> next()
  end

  def execute_instruction(%{op_code: 3,  input: []} = intcode) do
    %{intcode | status: :awaiting_input}
  end

  def execute_instruction(%{op_code: 3, paramaters: [dest], input: [input | tail]} = intcode) do
    intcode
    |> update_memory(dest, input)
    |> Map.put(:input, tail)
    |> next()
  end

  def execute_instruction(%{op_code: 4, evaluated_params: [value]} = intcode) do
    # IO.inspect(value, label: :output)
    # IO.inspect(intcode.operation_index, label: :index)

    intcode
    |> Map.put(:output, value)
    |> next()
  end

  def execute_instruction(%{op_code: 5, evaluated_params: [x, pointer]} = intcode) do
    next(intcode, pointer_adress: unless(x == 0, do: pointer))
  end

  def execute_instruction(%{op_code: 6, evaluated_params: [x, pointer]} = intcode) do
    next(intcode, pointer_adress: if(x == 0, do: pointer))
  end

  def execute_instruction(
        %{op_code: 7, evaluated_params: [x, y, _], paramaters: [_x, _y, dest]} = intcode
      ) do
    intcode
    |> update_memory(dest, if(x < y, do: 1, else: 0))
    |> next()
  end

  def execute_instruction(
        %{op_code: 8, evaluated_params: [x, y, _], paramaters: [_x, _y, dest]} = intcode
      ) do
    intcode
    |> update_memory(dest, if(x == y, do: 1, else: 0))
    |> next()
  end

  def execute_instruction(%{op_code: 99} = intcode), do: %{intcode | status: :halted}

  def next(intcode, opts \\ []) do
    next_ponter_adress =
      Keyword.get(opts, :pointer_adress) ||
        intcode.pointer_adress + (length(intcode.paramaters) + 1)

    run_program(%{
      intcode
      | pointer_adress: next_ponter_adress,
        operation_index: intcode.operation_index + 1,
        op_code: nil,
        paramaters: nil,
        paramater_modes: nil,
      evaluated_params: nil,
      status: :executing
    })
  end

  def evaluate_params(intcode) do
    params =
      intcode.paramater_modes
      |> Enum.zip(intcode.paramaters)
      |> Enum.map(&eval_params(&1, intcode))

    %{intcode | evaluated_params: params}
  end

  def eval_params({:immediate, value}, _intcode), do: value
  def eval_params({:position, value}, intcode), do: read(intcode.memory, value)

  def read_paramaters(%{op_code: 1} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 2} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 3} = i), do: read_paramaters(i, 1)
  def read_paramaters(%{op_code: 4} = i), do: read_paramaters(i, 1)
  def read_paramaters(%{op_code: 5} = i), do: read_paramaters(i, 2)
  def read_paramaters(%{op_code: 6} = i), do: read_paramaters(i, 2)
  def read_paramaters(%{op_code: 7} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 8} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 99} = i), do: read_paramaters(i, 0)

  def read_paramaters(i, n), do: %{i | paramaters: read_next(i.memory, i.pointer_adress, n)}

  def read_opcode(intcode) do
    {op_code, modes} =
      intcode.memory
      |> read(intcode.pointer_adress)
      |> parse_opcode()

    %{intcode | op_code: op_code, paramater_modes: modes}
  end

  def parse_opcode(int) do
    <<z::binary-size(1), y::binary-size(1), x::binary-size(1), op_code::binary>> =
      int |> to_string() |> String.pad_leading(5, "0")

    {String.to_integer(op_code), Enum.map([x, y, z], &paramater_modifiers/1)}
  end

  def paramater_modifiers("0"), do: :position
  def paramater_modifiers("1"), do: :immediate

  def update(memory, position, value), do: :array.set(position, value, memory)

  def read(memory, position), do: :array.get(position, memory)

  def read_next(_memory, _position, 0), do: []
  def read_next(memory, position, n), do: for(i <- 1..n, do: read(memory, position + i))
end
