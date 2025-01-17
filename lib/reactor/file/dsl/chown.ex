defmodule Reactor.File.Dsl.Chown do
  @moduledoc """
  A `chown` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.WaitFor, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            name: nil,
            path: nil,
            revert_on_undo?: false,
            uid: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          name: any,
          path: Template.t(),
          revert_on_undo?: boolean,
          uid: Template.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :chown,
      describe: """
      Change the owner of a file or directory.

      Uses `File.chown/2` behind the scenes.
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
          doc: "The path to the file or directory"
        ],
        uid: [
          type: Template.type(),
          required: true,
          doc: "The UID to set the file owner to"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Change the UID back to the original value on undo?"
        ]
      ]
    }
end
