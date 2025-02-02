defmodule Reactor.File.Step.IoRead do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      device: [
        type: :any,
        required: true,
        doc: "The IO device to read from"
      ]
    ],
    opt_schema: [
      line_or_chars: [
        type: {:or, [{:in, [:eof, :line]}, :non_neg_integer]},
        required: true,
        doc: "Controls how the device is iterated."
      ]
    ],
    moduledoc: "A step which runs `IO.read/2`"

  @doc false
  @impl true
  def mutate(arguments, context, options) do
    case io_read(arguments.device, options[:line_or_chars], context.current_step) do
      :eof -> {:ok, :eof}
      {:error, reason} -> {:error, reason}
      data -> {:ok, data}
    end
  end
end
