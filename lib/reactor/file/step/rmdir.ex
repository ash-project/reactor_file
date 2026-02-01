# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Rmdir do
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
        doc: "Recreate the directory if the Reactor is undoing changes"
      ]
    ],
    moduledoc: "A step which calls `File.rmdir/1`"

  defmodule Result do
    @moduledoc """
    The result of a `rmdir` step.

    Returns the path that was removed and the original `File.Stat` before the
    directory was removed.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: nil | File.Stat.t(),
            after_stat: nil,
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def mutate(arguments, context, _options) do
    with {:ok, stat} <- maybe_stat(arguments.path, [], context.current_step),
         :ok <- rmdir(arguments.path, context.current_step) do
      {:ok,
       %Result{path: arguments.path, before_stat: stat, changed?: is_struct(stat, File.Stat)}}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    with :ok <- mkdir(result.path, context.current_step) do
      write_stat(result.path, result.before_stat, [], context.current_step)
    end
  end
end
