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
    :status,
    :relative_base
  ]

  def new(memory, opts \\ []) do
    %__MODULE__{
      memory: :array.from_list(memory, 0),
      pointer_adress: Keyword.get(opts, :pointer_adress, 0),
      input: Keyword.get(opts, :input, []) |> List.wrap(),
      operation_index: 0,
      status: :new,
      relative_base: 0,
      output: []
    }
  end

  def put_input(intcode, value) do
    intcode
    |> Map.update!(:input, fn existing -> existing ++ [value] end)
    |> Map.put(:status, :ready_to_run)
  end

  def update_memory(intcode, position, value) do
    %{intcode | memory: update(intcode.memory, position, value)}
  end

  def update_relative_base(intcode, value) do
    Map.update!(intcode, :relative_base, fn rb -> rb + value end)
  end

  def read_from_memory(intcode, position) do
    read(intcode.memory, position)
  end

  def get_output(intcode, n \\ 1)
  def get_output(%{output: output}, 1), do: List.first(output)
  def get_output(%{output: output}, :all), do: output
  def get_output(%{output: output}, n), do: Enum.take(output, n)

  def clear_output(intcode), do: Map.put(intcode, :output, [])

  def run_program(%__MODULE__{} = intcode) do
    intcode
    |> read_opcode()
    |> read_paramaters()
    |> evaluate_params()
    |> execute_instruction()
  end

  def execute_instruction(%{op_code: 1, evaluated_params: [x, y | _]} = intcode) do
    intcode
    |> update_memory(get_destination(intcode), x + y)
    |> next()
  end

  def execute_instruction(%{op_code: 2, evaluated_params: [x, y | _]} = intcode) do
    intcode
    |> update_memory(get_destination(intcode), x * y)
    |> next()
  end

  def execute_instruction(%{op_code: 3, input: []} = intcode) do
    %{intcode | status: :awaiting_input}
  end

  def execute_instruction(%{op_code: 3, input: [input | tail]} = intcode) do
    intcode
    |> update_memory(get_destination(intcode), input)
    |> Map.put(:input, tail)
    |> next()
  end

  def execute_instruction(%{op_code: 4, evaluated_params: [value]} = intcode) do
    # IO.inspect(value, label: :output)
    # IO.inspect(intcode.operation_index, label: :index)

    intcode
    |> Map.update!(:output, &[value | &1])
    |> next()
  end

  def execute_instruction(%{op_code: 5, evaluated_params: [x, pointer]} = intcode) do
    next(intcode, pointer_adress: unless(x == 0, do: pointer))
  end

  def execute_instruction(%{op_code: 6, evaluated_params: [x, pointer]} = intcode) do
    next(intcode, pointer_adress: if(x == 0, do: pointer))
  end

  def execute_instruction(%{op_code: 7, evaluated_params: [x, y | _rest]} = intcode) do
    intcode
    |> update_memory(get_destination(intcode), if(x < y, do: 1, else: 0))
    |> next()
  end

  def execute_instruction(%{op_code: 8, evaluated_params: [x, y, _]} = intcode) do
    intcode
    |> update_memory(get_destination(intcode), if(x == y, do: 1, else: 0))
    |> next()
  end

  def execute_instruction(%{op_code: 9, evaluated_params: [x]} = intcode) do
    intcode
    |> update_relative_base(x)
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
  def eval_params({:position, value}, i), do: read(i.memory, value)
  def eval_params({:relative, value}, i), do: read(i.memory, i.relative_base + value)

  def read_paramaters(%{op_code: 1} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 2} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 3} = i), do: read_paramaters(i, 1)
  def read_paramaters(%{op_code: 4} = i), do: read_paramaters(i, 1)
  def read_paramaters(%{op_code: 5} = i), do: read_paramaters(i, 2)
  def read_paramaters(%{op_code: 6} = i), do: read_paramaters(i, 2)
  def read_paramaters(%{op_code: 7} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 8} = i), do: read_paramaters(i, 3)
  def read_paramaters(%{op_code: 9} = i), do: read_paramaters(i, 1)
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

  def get_destination(intcode) do
    if Enum.at(intcode.paramater_modes, length(intcode.paramaters) - 1) in [:relative] do
      List.last(intcode.paramaters) + intcode.relative_base
    else
      List.last(intcode.paramaters)
    end
  end

  def paramater_modifiers("0"), do: :position
  def paramater_modifiers("1"), do: :immediate
  def paramater_modifiers("2"), do: :relative

  def update(memory, position, value), do: :array.set(position, value, memory)

  def read(memory, position), do: :array.get(position, memory)

  def read_next(_memory, _position, 0), do: []
  def read_next(memory, position, n), do: for(i <- 1..n, do: read(memory, position + i))

  def parse(input) do
    if String.starts_with?(input, "input") do
      File.read!(input)
    else
      input
    end
    |> String.split([",", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

defimpl Inspect, for: Intcode do
  import Inspect.Algebra

  def inspect(intcode, opts) do
    to_inspect =
      intcode
      |> Map.drop([:__struct__])
      |> Map.update!(:memory, fn x ->
        if Keyword.get(opts.custom_options, :history, false) do
          x
        else
          "[ HISTORY ]"
        end
      end)
      |> Enum.to_list()
      |> Enum.sort()

    concat(["#Intcode<", to_doc(to_inspect, Map.put(opts, :charlists, false)), ">"])
  end
end
