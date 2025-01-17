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
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of a `rmdir` step.

    Returns the path that was removed and the original `File.Stat` before the
    directory was removed.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: nil | File.Stat.t(),
            after_stat: nil,
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, _options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, stat} <- maybe_stat(arguments[:path], [], context.current_step),
         :ok <- rmdir(arguments[:path], context.current_step) do
      {:ok,
       %Result{path: arguments[:path], before_stat: stat, changed?: is_struct(stat, File.Stat)}}
    end
  end

  @doc false
  @impl true
  def can?(%{impl: {_, options}}, :undo) do
    with {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      options[:recreate_on_undo?]
    end
  end

  def can?(_, :undo), do: false
  def can?(step, capability), do: super(step, capability)

  @doc false
  @impl true
  def undo(result, _, _, _) when result.changed? == false, do: :ok

  def undo(result, _arguments, context, options) do
    if Keyword.get(options, :recreate_on_undo?) && is_struct(result.before_stat, File.Stat) do
      do_undo(result, context.current_step)
    else
      :ok
    end
  end

  defp do_undo(result, step) do
    with :ok <- mkdir(result.path, step),
         :ok <- chown(result.path, result.before_stat.uid, step),
         :ok <- chgrp(result.path, result.before_stat.gid, step) do
      chmod(result.path, result.before_stat.mode, step)
    end
  end
end
