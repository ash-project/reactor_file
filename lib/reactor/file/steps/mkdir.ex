defmodule Reactor.File.Step.Mkdir do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the directory to create"
                ]
              )

  @opt_schema Spark.Options.new!(
                minus_p: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Whether or not to create any missing intermediate directories"
                ]
              )

  @moduledoc """
  A step which calls `File.mkdir/1` or `File.mkdir_p/1`.

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
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         :ok <- mkdir(arguments[:path], options[:minus_p]) do
      {:ok, arguments[:path]}
    end
  end

  defp mkdir(path, false), do: File.mkdir(path)
  defp mkdir(path, true), do: File.mkdir_p(path)
end
