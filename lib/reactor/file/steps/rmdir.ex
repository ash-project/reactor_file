defmodule Reactor.File.Step.Rmdir do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the directory to create"
                ]
              )

  @opt_schema Spark.Options.new!([])

  @moduledoc """
  A step which calls `File.rmdir/1`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}
  """
  use Reactor.Step

  @doc false
  @impl true
  def run(arguments, _context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, _options} <- Spark.Options.validate(options, @opt_schema),
         :ok <- File.rmdir(arguments[:path]) do
      {:ok, arguments[:path]}
    end
  end
end
