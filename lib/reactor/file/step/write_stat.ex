# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.WriteStat do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path to modify"
      ],
      stat: [
        type: {:struct, File.Stat},
        required: true,
        doc: "The stat to write"
      ]
    ],
    opt_schema: [
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Revert to the original state if the Reactor is undoing changes"
      ],
      time: [
        type: {:in, [:universal, :local, :posix]},
        required: false,
        default: :posix,
        doc: "What format to return the file times in. See `File.stat/2` for more."
      ]
    ],
    moduledoc: "A step which calls `File.write_stat/2`"

  defmodule Result do
    @moduledoc """
    The result of a `write_stat` step.

    Returns the path that was modified, plus the before and after stats.
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
  def mutate(arguments, context, options) do
    with {:ok, before_stat} <- stat(arguments.path, [], context.current_step),
         :ok <-
           write_stat(
             arguments.path,
             arguments.stat,
             [time: options[:time]],
             context.current_step
           ),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: before_stat != after_stat
       }}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    write_stat(result.path, result.before_state, [], context.current_step)
  end
end
