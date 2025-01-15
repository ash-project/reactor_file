defmodule Reactor.File.Dsl.Mkdir do
  @moduledoc """
  A `mkdir` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.WaitFor, Template}

  defstruct __identifier__: nil, description: nil, name: nil, path: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          description: nil | String.t(),
          name: any,
          path: Path.t()
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :mkdir,
      describe: """
      Creates a directory.

      Uses `File.mkdir/1` behind the scenes.
      """,
      target: __MODULE__,
      identifier: :name,
      args: [:name],
      recursive_as: :steps,
      entities: [arguments: [WaitFor.__entity__()]],
      imports: [Reactor.Dsl.Argument],
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
          doc: "The path of the directory to create"
        ]
      ]
    }
end
