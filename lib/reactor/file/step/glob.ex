defmodule Reactor.File.Step.Glob do
  @arg_schema Spark.Options.new!(
                pattern: [
                  type: :string,
                  required: true,
                  doc:
                    "A pattern used to select files. See `Path.wildcard/2` for more information."
                ]
              )

  @opt_schema Spark.Options.new!(
                match_dot: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc:
                    "Whether or not files starting with a `.` will be matched by the pattern. See `Path.wildcard/2` for more information."
                ]
              )

  @moduledoc """
  A step which calls `Path.wildcard/2`.

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
      {:ok, Path.wildcard(arguments[:pattern], options)}
    end
  end
end
