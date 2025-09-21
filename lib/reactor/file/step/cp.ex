# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Cp do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
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
    ],
    opt_schema: [
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
    ],
    moduledoc: "A step which calls `File.cp/3`"

  alias Reactor.File.OverwriteError

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
  def mutate(arguments, context, options) do
    with {:ok, before_stat} <- maybe_stat(arguments.target, [], context.current_step),
         :ok <-
           overwrite_check(
             arguments.target,
             context.current_step,
             before_stat,
             options[:overwrite?]
           ),
         {:ok, backup_file} <- maybe_backup(arguments.target, context, options[:revert_on_undo?]),
         :ok <- cp(arguments[:source], arguments.target, context.current_step),
         {:ok, after_stat} <- stat(arguments.target, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.target,
         before_stat: before_stat,
         original: backup_file,
         after_stat: after_stat,
         changed?: true
       }}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    step = context.current_step

    with :ok <- cp(result.original, result.path, step),
         :ok <- chown(result.path, result.before_stat.uid, step),
         :ok <- chgrp(result.path, result.before_stat.gid, step),
         :ok <- chmod(result.path, result.before_stat.mode, step) do
      rm(result.original, step)
    end
  end

  defp overwrite_check(_path, _step, _stat, true), do: :ok
  defp overwrite_check(_path, _step, nil, _overwrite?), do: :ok

  defp overwrite_check(path, step, stat, false),
    do:
      {:error,
       OverwriteError.exception(step: step, file: path, message: "#{stat.type} already exists")}

  defp maybe_backup(path, context, undoable?) do
    if File.exists?(path) && undoable? do
      backup_file(path, context)
    else
      {:ok, nil}
    end
  end
end
