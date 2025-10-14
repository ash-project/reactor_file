# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.OpenFile do
  @moduledoc false
  alias Reactor.File.Types

  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the file to open"
      ]
    ],
    opt_schema: [
      modes: [
        type: {:or, [Types.file_modes(), {:literal, :ram}]},
        required: true,
        doc: "The mode to open the file with"
      ]
    ],
    moduledoc: "A step which calls `File.open/2`"

  @doc false
  @impl true
  def mutate(arguments, context, options) do
    open_file(arguments.path, options[:modes], context.current_step)
  end
end
