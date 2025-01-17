defmodule Reactor.File.Step.Chmod do
  @arg_schema Spark.Options.new!(
                mode: [
                  type: :pos_integer,
                  required: true,
                  doc: "The mode to set the file to"
                ],
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the file to change"
                ]
              )

  @opt_schema Spark.Options.new!(
                revert_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Change the file mode back to the original value on undo?"
                ]
              )

  @moduledoc """
  A step which calls `File.chmod/2`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}

  ## Returns

  The original GID of the file before modification.
  """
  use Reactor.Step

  @doc false
  @impl true
  def run(arguments, _context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, _options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, %{mode: mode}} <- File.stat(arguments[:path]),
         :ok <- File.chmod(arguments[:path], arguments[:mode]) do
      {:ok, mode}
    end
  end

  @doc false
  @impl true
  def can?(%{impl: {_, options}}, :undo) do
    with {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      options[:revert_on_undo?]
    end
  end

  def can?(_, :undo), do: false
  def can?(step, capability), do: super(step, capability)

  @doc false
  @impl true
  def undo(mode, arguments, _context, options) do
    if Keyword.get(options, :revert_on_undo?) do
      File.chmod(arguments.path, mode)
    else
      :ok
    end
  end
end
