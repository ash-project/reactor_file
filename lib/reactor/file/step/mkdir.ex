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
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of a `mkdir` step.

    Contains the path being changed, and the stats before and after the change.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, before_stat} <- maybe_stat(arguments[:path], [], context.current_step),
         :ok <-
           maybe_mkdir(arguments[:path], before_stat, options[:minus_p], context.current_step),
         {:ok, after_stat} <- stat(arguments[:path], [], context.current_step) do
      {:ok,
       %Result{
         path: arguments[:path],
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: is_nil(before_stat)
       }}
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
  def undo(result, _, _, _) when result.changed? == false, do: :ok

  def undo(result, _arguments, context, options) do
    if Keyword.get(options, :remove_on_undo?) do
      rmdir(result.path, context.current_step)
    else
      :ok
    end
  end

  defp maybe_mkdir(_path, %File.Stat{type: :directory}, _, _), do: :ok
  defp maybe_mkdir(path, _, true, step), do: mkdir_p(path, step)
  defp maybe_mkdir(path, _, false, step), do: mkdir(path, step)
end
