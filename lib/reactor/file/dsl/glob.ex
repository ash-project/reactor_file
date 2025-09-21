# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.Glob do
  @moduledoc """
  A `glob` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            guards: [],
            name: nil,
            pattern: nil,
            match_dot: false

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          pattern: Template.t(),
          match_dot: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :glob,
      describe: """
      Searches for files matching the provided pattern.

      Uses `Path.wildcard/2` under the hood.
      """,
      target: __MODULE__,
      identifier: :name,
      args: [:name],
      recursive_as: :steps,
      entities: [
        arguments: [WaitFor.__entity__()],
        guards: [Guard.__entity__(), Where.__entity__()]
      ],
      imports: [Argument],
      schema: [
        name: [
          type: :atom,
          required: true,
          doc:
            "A unique name for the step. Used when choosing the return value of the Reactor and for arguments into other steps"
        ],
        description: [
          type: :string,
          required: false,
          doc: "An optional description for the step"
        ],
        pattern: [
          type: Template.type(),
          required: true,
          doc: "A pattern used to select files. See `Path.wildcard/2` for more information."
        ],
        match_dot: [
          type: :boolean,
          required: false,
          default: false,
          doc:
            "Whether or not files starting with a `.` will be matched by the pattern. See `Path.wildcard/2` for more information."
        ]
      ]
    }
end
