# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Mkdir do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the directory to create"
      ]
    ],
    opt_schema: [
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Remove the created directory if the Reactor is undoing changes"
      ]
    ]

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
  def mutate(arguments, context, _options) do
    with {:ok, before_stat} <- maybe_stat(arguments.path, [], context.current_step),
         :ok <- mkdir(arguments.path, context.current_step),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: is_nil(before_stat)
       }}
    end
  end

  @doc false
  def revert(result, context, _options) do
    rmdir(result.path, context.current_step)
  end
end
