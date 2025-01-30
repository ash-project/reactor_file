defmodule Reactor.File.Dsl.CpR do
  @moduledoc """
  A `cp_r` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            guards: [],
            overwrite?: true,
            name: nil,
            revert_on_undo?: false,
            source: nil,
            target: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          overwrite?: boolean,
          name: any,
          revert_on_undo?: boolean,
          source: Template.t(),
          target: Template.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :cp_r,
      describe: """
      Copy the source file or directories to the destination.

      Uses `File.cp_r/2`.
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
        source: [
          type: Template.type(),
          required: true,
          doc: "The path to the source file"
        ],
        target: [
          type: Template.type(),
          required: true,
          doc: "The path to the target file"
        ],
        overwrite?: [
          type: :boolean,
          required: false,
          default: true,
          doc: "Whether or not to overwrite the target if it already exists"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc:
            "Revert back to the initial state on undo (either by removing the target or by setting it back to it's original content)"
        ]
      ]
    }
end
