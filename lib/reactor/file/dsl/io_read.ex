# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.IoRead do
  @moduledoc """
  An `io_read` DSL entity for the `Reactor.File` extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            device: nil,
            guards: [],
            line_or_chars: nil,
            name: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          device: Template.t(),
          guards: [Reactor.Guard.Build.t()],
          line_or_chars: :eof | :line | non_neg_integer(),
          name: any
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :io_read,
      describe: """
      Reads from an IO device

      Uses `IO.read/2`.
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
        line_or_chars: [
          type: {:or, [{:in, [:eof, :line]}, :non_neg_integer]},
          required: true,
          doc: "Controls how the device is iterated."
        ]
      ]
    }
end
