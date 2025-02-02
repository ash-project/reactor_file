defmodule Reactor.File.Step.IoBinStream do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      device: [
        type: :any,
        required: true,
        doc: "The IO device to stream"
      ]
    ],
    opt_schema: [
      line_or_bytes: [
        type: {:or, [{:literal, :line}, :non_neg_integer]},
        required: true,
        doc: "Controls how the device is iterated."
      ]
    ],
    moduledoc: "A step which runs `IO.binstream/2`"

  @doc false
  @impl true
  def mutate(arguments, _context, options) do
    {:ok, IO.binstream(arguments.device, options[:line_or_bytes])}
  end
end
