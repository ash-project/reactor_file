# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Glob do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      pattern: [
        type: :string,
        required: true,
        doc: "A pattern used to select files. See `Path.wildcard/2` for more information."
      ]
    ],
    opt_schema: [
      match_dot: [
        type: :boolean,
        required: false,
        default: false,
        doc:
          "Whether or not files starting with a `.` will be matched by the pattern. See `Path.wildcard/2` for more information."
      ]
    ],
    moduledoc: "A step which calls `Path.wildcard/2`"

  @doc false
  @impl true
  def mutate(arguments, _context, options) do
    {:ok, Path.wildcard(arguments.pattern, options)}
  end
end
