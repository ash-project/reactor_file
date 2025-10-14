# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Chmod do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      mode: [
        type: :pos_integer,
        required: true,
        doc: "The mode to set the file to"
      ],
      path: [
        type: :string,
        required: true,
        doc: "The path of the file to change"
      ]
    ],
    opt_schema: [
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Change the file mode back to the original value on undo?"
      ]
    ],
    moduledoc: "A step which calls `File.chmod/2`"

  defmodule Result do
    @moduledoc """
    The result of a `chmod` step.

    Contains the path that was changed, as well as before and after stats.
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
  def mutate(arguments, context, _options) do
    with {:ok, before_stat} <- stat(arguments.path, [], context.current_step),
         :ok <- chmod(arguments.path, arguments.mode, context.current_step),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: before_stat.mode != after_stat.mode
       }}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    chmod(result.path, result.before_stat.mode, context.current_step)
  end
end
