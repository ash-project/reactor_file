defmodule Reactor.File.Dsl.Rm do
  @moduledoc """
  A `rm` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.WaitFor, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            name: nil,
            path: nil,
            revert_on_undo?: false

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          name: any,
          path: Path.t(),
          revert_on_undo?: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :rm,
      describe: """
      Removes a file.

      Uses `File.rm/1` behind the scenes.
      """,
      target: __MODULE__,
      identifier: :name,
      args: [:name],
      recursive_as: :steps,
      entities: [arguments: [WaitFor.__entity__()]],
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
          doc: "The path to the file to remove"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Replace the original file if the Reactor is undoing changes"
        ]
      ]
    }
end
