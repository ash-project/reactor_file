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
                ],
                remove_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Remove the created directory if the Reactor is undoing changes"
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

  @doc false
  @impl true
  def can?(%{impl: {_, options}}, :undo) do
    with {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      options[:remove_on_undo?]
    end
  end

  def can?(_, :undo), do: false
  def can?(step, capability), do: super(step, capability)

  @doc false
  @impl true
  def undo(_path, arguments, _context, options) do
    if Keyword.get(options, :remove_on_undo?) do
      with {:ok, _} <- File.rm_rf(arguments.path) do
        :ok
      end
    else
      :ok
    end
  end

  defp mkdir(path, false), do: File.mkdir(path)
  defp mkdir(path, true), do: File.mkdir_p(path)
end
