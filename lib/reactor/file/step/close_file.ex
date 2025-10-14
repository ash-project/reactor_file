# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.CloseFile do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      device: [
        type: :any,
        required: true,
        doc: "The IO device to close"
      ]
    ],
    opt_schema: [],
    moduledoc: "A step which calls `File.close/1`"

  @doc false
  @impl true
  def mutate(arguments, context, _options) do
    with :ok <- close_file(arguments.device, context.current_step) do
      {:ok, :ok}
    end
  end
end
