# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.WriteFile do
  @moduledoc false
  alias Reactor.File.Types

  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path to modify"
      ],
      content: [
        type: :string,
        required: true,
        doc: "The stat to write"
      ]
    ],
    opt_schema: [
      modes: [
        type: Types.file_modes(),
        required: false,
        default: [],
        doc: "See `t:File.mode/0`."
      ],
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Revert to the original state if the Reactor is undoing changes"
      ]
    ],
    moduledoc: "A step which calls `File.write/2`"

  defmodule Result do
    @moduledoc """
    The result of a `write` step.

    Returns the path that was modified, plus the before and after stats.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, original: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            original: Path.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def mutate(arguments, context, options) do
    with {:ok, before_stat} <- maybe_stat(arguments.path, [], context.current_step),
         {:ok, backup} <-
           maybe_backup_file(arguments.path, before_stat, context, options[:revert_on_undo?]),
         :ok <-
           write_file(arguments.path, arguments.content, options[:modes], context.current_step),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: before_stat,
         after_stat: after_stat,
         original: backup,
         changed?: before_stat != after_stat
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
