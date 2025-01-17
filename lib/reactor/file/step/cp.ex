defmodule Reactor.File.Step.Cp do
  @arg_schema Spark.Options.new!(
                source: [
                  type: :string,
                  required: true,
                  doc: "The path to the source file"
                ],
                target: [
                  type: :string,
                  required: true,
                  doc: "The path to the target file"
                ]
              )

  @opt_schema Spark.Options.new!(
                overwrite?: [
                  type: :boolean,
                  required: false,
                  default: true,
                  doc: "Whether or not to overwrite the target if it already exists"
                ],
                revert_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc:
                    "Revert back to the initial state on undo (either by removing the target or by setting it back to it's original content)"
                ]
              )

  @moduledoc """
  A step which copies a file.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}

  ## Returns

  A `Reactor.File.Step.FileCp.Result`
  """
  use Reactor.Step
  alias Reactor.File.OverwriteError
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of a file copying operation.
    """

    defstruct path: nil, before_stat: nil, after_stat: nil, original_file: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            original_file: nil | Path.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         target <- Keyword.fetch!(arguments, :target),
         {:ok, before_stat} <- maybe_stat(target, [], context.current_step),
         :ok <-
           check_overwrite_state(target, context.current_step, before_stat, options[:overwrite?]),
         {:ok, backup_file} <-
           maybe_backup_file(target, context, options[:revert_on_undo?]),
         :ok <- cp(arguments[:source], target, context.current_step),
         {:ok, after_stat} <- stat(target, [], context.current_step) do
      {:ok,
       %Result{
         path: target,
         before_stat: before_stat,
         original_file: backup_file,
         after_stat: after_stat,
         changed?: true
       }}
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
  def undo(result, _, _, _) when result.changed? == false, do: :ok

  def undo(result, _arguments, context, options) do
    if Keyword.get(options, :revert_on_undo?) && is_struct(result.before_stat, File.Stat) do
      do_undo(result, context.current_step)
    else
      :ok
    end
  end

  defp check_overwrite_state(_path, _step, _stat, true), do: :ok
  defp check_overwrite_state(_path, _step, nil, _overwrite?), do: :ok

  defp check_overwrite_state(path, step, stat, false),
    do:
      {:error,
       OverwriteError.exception(step: step, file: path, message: "#{stat.type} already exists")}

  defp maybe_backup_file(path, context, undoable?) do
    if File.exists?(path) && undoable? do
      backup_file(path, context)
    else
      {:ok, nil}
    end
  end

  defp do_undo(result, step) do
    with :ok <- cp(result.original_file, result.path, step),
         :ok <- chown(result.path, result.before_stat.uid, step),
         :ok <- chgrp(result.path, result.before_stat.gid, step),
         :ok <- chmod(result.path, result.before_stat.mode, step) do
      rm(result.original_file, step)
    end
  end
end
