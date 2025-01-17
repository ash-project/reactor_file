defmodule Reactor.File.Step.Rmdir do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the directory to create"
                ]
              )

  @opt_schema Spark.Options.new!(
                recreate_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Recreate the directory if the Reactor is undoing changes"
                ]
              )

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

  @doc false
  @impl true
  def can?(%{impl: {_, options}}, :undo) do
    with {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      options[:recreate_on_undo?]
    end
  end

  def can?(step, cap), do: super(step, cap)

  @doc false
  @impl true
  def undo(_path, arguments, _context, options) do
    if Keyword.get(options, :recreate_on_undo?) do
      File.mkdir(arguments.path)
    else
      :ok
    end
  end
end
