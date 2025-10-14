# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Chgrp do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      gid: [
        type: :pos_integer,
        required: true,
        doc: "The GID to change the file to"
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
        doc: "Change the GID back to the original value on undo?"
      ]
    ],
    moduledoc: "A step which calls `File.chgrp/2`."

  defmodule Result do
    @moduledoc """
    The result of a `chgrp` step.

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
    with {:ok, before_stat} <- stat(arguments.path, [], context.current_step),
         :ok <- chgrp(arguments.path, arguments.gid, context.current_step),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: before_stat.gid != after_stat.gid
       }}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    chgrp(result.path, result.before_stat.gid, context.current_step)
  end
end
