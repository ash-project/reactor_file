defmodule Reactor.File.Step.CpR do
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
                ],
                dereference_symlinks?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc:
                    " By default, this function will copy symlinks by creating symlinks that point to the same location. This option forces symlinks to be dereferenced and have their contents copied instead when set to true. If the dereferenced files do not exist, than the operation fails."
                ]
              )

  @moduledoc """
  A step which copies a file.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}

  ## Returns

  A `Reactor.File.Step.CpR.Result`
  """
  use Reactor.Step
  alias Reactor.File.OverwriteError
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of a file copying operation.
    """

    defstruct path: nil, before_stat: nil, after_stat: nil, original: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            original: nil | Path.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, options} <- Spark.Options.validate(options, @opt_schema),
         source <- Keyword.fetch!(arguments, :source),
         target <- Keyword.fetch!(arguments, :target),
         {:ok, before_stat} <- maybe_stat(target, [], context.current_step),
         :ok <-
           overwrite_check(
             source,
             target,
             before_stat,
             context.current_step,
             options[:overwrite?]
           ),
         {:ok, backup_file} <-
           maybe_backup(target, context, options[:revert_on_undo?]),
         cp_opts <- cp_ops(options),
         :ok <- cp_r(source, target, cp_opts, context.current_step),
         {:ok, after_stat} <- stat(target, [], context.current_step) do
      {:ok,
       %Result{
         path: target,
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

  defp cp_ops(options) do
    [
      dereference_symlinks: options[:dereference_symlinks?]
    ]
  end

  defp maybe_backup(path, context, true) do
    cond do
      File.regular?(path) ->
        backup_file(path, context)

      File.dir?(path) ->
        backup_dir(path, context)

      true ->
        {:ok, nil}
    end
  end

  defp maybe_backup(_path, _context, _undoable?), do: {:ok, nil}

  # defp overwrite_check(source, target, before_stat, step, overwrite?)
  defp overwrite_check(_source, _target, nil, _step, _overwrite?), do: :ok
  defp overwrite_check(_source, _target, _stat, _step, true), do: :ok

  defp overwrite_check(source, target, %{type: :directory}, step, false) do
    if File.dir?(source) do
      recursive_overwrite_check(source, target, step)
    else
      {:error,
       OverwriteError.exception(step: step, file: target, message: "directory already exists")}
    end
  end

  defp overwrite_check(_source, target, stat, step, false),
    do:
      {:error,
       OverwriteError.exception(step: step, file: target, message: "#{stat.type} already exists")}

  defp recursive_overwrite_check(source, target, step) do
    source
    |> Path.join("**/*")
    |> Path.wildcard(match_dot: true)
    |> Enum.reduce_while(:ok, fn source_file, :ok ->
      target_file =
        source_file
        |> Path.relative_to(source)
        |> then(&Path.join(target, &1))

      case File.stat(target_file) do
        {:ok, stat} ->
          {:halt,
           {:error,
            OverwriteError.exception(
              step: step,
              file: target_file,
              message: "#{stat.type} already exists"
            )}}

        {:error, _} ->
          {:cont, :ok}
      end
    end)
  end

  defp do_undo(result, step) when is_nil(result.original), do: rm_rf(result.path, step)

  defp do_undo(result, step) do
    with :ok <- rm_rf(result.path, step),
         :ok <- cp_r(result.original, result.path, [], step),
         :ok <- chown(result.path, result.before_stat.uid, step),
         :ok <- chgrp(result.path, result.before_stat.gid, step),
         :ok <- chmod(result.path, result.before_stat.mode, step) do
      rm_rf(result.original, step)
    end
  end
end
