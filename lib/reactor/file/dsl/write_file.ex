# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.WriteFile do
  @moduledoc """
  A `write_file` DSL entity for the `Reactor.File` DSL extension.
  """
  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, File.Types, Template}

  defstruct __identifier__: nil,
            __spark_metadata__: nil,
            arguments: [],
            content: nil,
            description: nil,
            guards: [],
            name: nil,
            path: nil,
            revert_on_undo?: false

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Dsl.Argument],
          content: Template.t(),
          description: nil,
          guards: [Reactor.Guard.Build.t()],
          name: any,
          path: Template.t(),
          revert_on_undo?: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :write_file,
      describe: """
      Writes the given content to the file at the given path.
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
        path: [
          type: Template.type(),
          required: true,
          doc: "The path to the file to modify"
        ],
        content: [
          type: Template.type(),
          required: true,
          doc: "The content to write"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Revert to the original state when undoing changes"
        ],
        modes: [
          type: Types.file_modes(),
          required: false,
          default: [],
          doc: "See `t:File.mode/0`."
        ]
      ]
    }
end
