# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.IoWrite do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      device: [
        type: :any,
        required: true,
        doc: "The IO device to write to"
      ],
      chardata: [
        type: :any,
        required: true,
        doc: "The content to write to the device"
      ]
    ],
    opt_schema: [],
    moduledoc: "A step which runs `IO.write/2`"

  @doc false
  @impl true
  def mutate(arguments, _context, _options) do
    {:ok, IO.write(arguments.device, arguments.chardata)}
  end
end
