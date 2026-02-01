# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.IoWrite do
  @moduledoc """
  An `io_write` DSL entity for the `Reactor.File` extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            __spark_metadata__: nil,
            arguments: [],
            chardata: nil,
            description: nil,
            device: nil,
            guards: [],
            name: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          chardata: Template.t(),
          description: nil | String.t(),
          device: Template.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :io_write,
      describe: """
      Writes to an IO device

      Uses `IO.write/2`.
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
        device: [
          type: Template.type(),
          required: true,
          doc: "The IO device to read from"
        ],
        chardata: [
          type: Template.type(),
          required: true,
          doc: "The data to write to the IO device"
        ]
      ]
    }
end
