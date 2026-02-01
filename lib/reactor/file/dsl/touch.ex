# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.Touch do
  @moduledoc """
  A `touch` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            __spark_metadata__: nil,
            arguments: [],
            description: nil,
            guards: [],
            name: nil,
            path: nil,
            revert_on_undo?: false,
            time: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          path: Template.t(),
          revert_on_undo?: boolean,
          time: Template.t()
        }
  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :touch,
      describe: """
      Update the mtime and atime of a file.

      Uses `File.touch/2`.
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
          doc: "The path of the directory to remove"
        ],
        time: [
          type: Template.type(),
          required: false,
          doc: "The time to change the file to."
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Recreate the directory if the Reactor is undoing changes"
        ]
      ]
    }
end
