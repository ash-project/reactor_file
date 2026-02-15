# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.ReadLink do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the link to read"
      ]
    ],
    opt_schema: [],
    moduledoc: "A step which calls `File.read_link/1`"

  @doc false
  @impl true
  def mutate(arguments, context, _options) do
    read_link(arguments.path, context.current_step)
  end
end
