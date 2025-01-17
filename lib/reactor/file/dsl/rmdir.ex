defmodule Reactor.File.Dsl.Rmdir do
  @moduledoc """
  A `rmdir` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.WaitFor, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            name: nil,
            path: nil,
            recreate_on_undo?: false

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          name: any,
          path: Path.t(),
          recreate_on_undo?: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :rmdir,
      describe: """
      Removes a directory.

      Uses `File.rmdir/1` behind the scenes.
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
          doc: "The path of the directory to remove"
        ],
        recreate_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Recreate the directory if the Reactor is undoing changes"
        ]
      ]
    }
end
