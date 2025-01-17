defmodule Reactor.File.Step.Stat do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the file to inspect"
                ]
              )

  @opt_schema Spark.Options.new!(
                time: [
                  type: {:in, [:universal, :local, :posix]},
                  required: false,
                  default: :posix,
                  doc: "What format to return the file times in. See `File.stat/2` for more."
                ]
              )

  @moduledoc """
  A step which calls `File.stat/2`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}
  """
  use Reactor.Step

  @doc false
  @impl true
  def run(arguments, _context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      File.stat(arguments[:path], time: options[:time])
    end
  end
end
