# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.ReadLink do
  @moduledoc """
  A `read_link` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            __spark_metadata__: nil,
            arguments: [],
            description: nil,
            guards: [],
            name: nil,
            path: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          path: Template.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :read_link,
      describe: """
      Reads a symbolic link.

      Uses `File.read_link/1`.
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
          doc: "The path to the link to read"
        ]
      ]
    }
end
