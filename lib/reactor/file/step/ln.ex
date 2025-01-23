defmodule Reactor.File.Step.Ln do
  @arg_schema Spark.Options.new!(
                existing: [
                  type: :string,
                  required: true,
                  doc: "The path to the existing file"
                ],
                new: [
                  type: :string,
                  required: true,
                  doc: "The path to the new file"
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
                  doc: "Revert back to the initial state on undo"
                ],
                symbolic?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Create a symbolic link instead of a hard link"
                ]
              )
  @moduledoc """
  A step which creates a link from `existing` to `new`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}
  """
  use Reactor.Step
  alias Reactor.File.OverwriteError
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of the `ln` operation.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, original: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            original: nil | Path.t(),
            changed?: boolean()
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         new <- Keyword.fetch!(arguments, :new),
         {:ok, before_stat} <- maybe_stat(new, [], context.current_step),
         {:ok, backup_file} <- maybe_backup_file(new, context, options[:revert_on_undo?]),
         :ok <-
           overwrite_check(new, context.current_step, before_stat, options[:overwrite?]),
         :ok <- do_ln(arguments[:existing], new, options[:symbolic?], context.current_step),
         {:ok, after_stat} <- stat(new, [], context.current_step) do
      {:ok,
       %Result{
         path: new,
         before_stat: before_stat,
         original: backup_file,
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
    if Keyword.get(options, :revert_on_undo?) do
      do_undo(result, context.current_step)
    else
      :ok
    end
  end

  defp overwrite_check(_path, _step, nil, _overwrite?), do: :ok

  defp overwrite_check(path, step, stat, true) when is_struct(stat, File.Stat),
    do: rm(path, step)

  defp overwrite_check(path, step, stat, false) when is_struct(stat, File.Stat),
    do:
      {:error,
       OverwriteError.exception(
         step: step,
         file: path,
         message: "#{stat.type} already exists"
       )}

  defp maybe_backup_file(path, context, undoable?) do
    if File.exists?(path) && undoable? do
      backup_file(path, context)
    else
      {:ok, nil}
    end
  end

  defp do_undo(result, step) when is_nil(result.original),
    do: rm(result.path, step)

  defp do_undo(result, step) do
    with :ok <- cp(result.original, result.path, step),
         :ok <- chown(result.path, result.before_stat.uid, step),
         :ok <- chgrp(result.path, result.before_stat.gid, step),
         :ok <- chmod(result.path, result.before_stat.mode, step) do
      rm(result.original, step)
    end
  end

  defp do_ln(existing, new, false, step), do: ln(existing, new, step)
  defp do_ln(existing, new, true, step), do: ln_s(existing, new, step)
end
