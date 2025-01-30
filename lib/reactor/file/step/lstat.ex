defmodule Reactor.File.Step.Lstat do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the file to inspect"
      ]
    ],
    opt_schema: [
      time: [
        type: {:in, [:universal, :local, :posix]},
        required: false,
        default: :posix,
        doc: "What format to return the file times in. See `File.stat/2` for more."
      ]
    ],
    moduledoc: "A step which calls `File.lstat/2`"

  @doc false
  @impl true
  def mutate(arguments, context, options) do
    lstat(arguments.path, [time: options[:time]], context.current_step)
  end
end
