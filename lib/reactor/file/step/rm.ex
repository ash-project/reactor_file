# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Rm do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the directory to remove"
      ]
    ],
    opt_schema: [
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Replace the removed file if the Reactor is undoing changes"
      ]
    ],
    moduledoc: "A step which calls `File.rm/1`"

  defmodule Result do
    @moduledoc """
    The result of the `rm` step.
    """
    defstruct path: nil, before_stat: nil, original: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: nil | File.Stat.t(),
            original: Path.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def mutate(arguments, context, options) do
    with {:ok, stat} <- stat(arguments.path, [], context.current_step),
         {:ok, backup} <-
           maybe_backup_file(arguments.path, stat, context, options[:revert_on_undo?]),
         :ok <- rm(arguments.path, context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: stat,
         original: backup,
         changed?: true
       }}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    step = context.current_step

    if File.exists?(result.original) do
      with :ok <- cp(result.original, result.path, step),
           :ok <- write_stat(result.path, result.before_stat, [], step) do
        rm(result.original, step)
      end
    else
      :ok
    end
  end

  defp maybe_backup_file(path, %{type: :regular}, context, true), do: backup_file(path, context)
  defp maybe_backup_file(_, _, _, _), do: {:ok, nil}
end
