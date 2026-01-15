# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.OpenFile do
  @moduledoc """
  An `open_file` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, File.Types, Template}

  defstruct __identifier__: nil,
            __spark_metadata__: nil,
            arguments: [],
            description: nil,
            guards: [],
            name: nil,
            modes: [],
            path: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          modes: File.mode() | :ram,
          path: Template.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :open_file,
      describe: """
      Opens a file.

      Uses `File.open/2`.
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
          doc: "The path to the file to open"
        ],
        modes: [
          type: {:or, [Types.file_modes(), {:literal, :ram}]},
          required: true,
          doc: "The mode to open the file with"
        ]
      ]
    }
end
