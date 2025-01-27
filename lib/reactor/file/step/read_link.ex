defmodule Reactor.File.Step.ReadLink do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the link to read"
                ]
              )

  @moduledoc """
  A step which calls `File.stat/2`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  None
  """
  use Reactor.Step
  import Reactor.File.Ops

  @doc false
  @impl true
  def run(arguments, context, _options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema) do
      read_link(arguments[:path], context.current_step)
    end
  end
end
