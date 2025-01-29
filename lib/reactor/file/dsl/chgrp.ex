defmodule Reactor.File.Dsl.Chgrp do
  @moduledoc """
  A `chgrp` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            gid: nil,
            guards: [],
            name: nil,
            path: nil,
            revert_on_undo?: false

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          gid: Template.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          path: Template.t(),
          revert_on_undo?: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :chgrp,
      describe: """
      Change the group of a file or directory.

      Uses `File.chgrp/2` behind the scenes.
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
          doc: "The path to the file or directory"
        ],
        gid: [
          type: Template.type(),
          required: true,
          doc: "The GID to set the file group to"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Change the GID back to the original value on undo?"
        ]
      ]
    }
end
