# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.IoStream do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      device: [
        type: :any,
        required: true,
        doc: "The IO device to stream"
      ]
    ],
    opt_schema: [
      line_or_codepoints: [
        type: {:or, [{:literal, :line}, :non_neg_integer]},
        required: true,
        doc: "Controls how the device is iterated."
      ]
    ],
    moduledoc: "A step which runs `IO.stream/2`"

  @doc false
  @impl true
  def mutate(arguments, _context, options) do
    {:ok, IO.stream(arguments.device, options[:line_or_codepoints])}
  end
end
