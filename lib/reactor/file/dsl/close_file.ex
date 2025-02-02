defmodule Reactor.File.Dsl.CloseFile do
  @moduledoc """
  A `close_file` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            device: nil,
            guards: [],
            name: nil

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          device: Template.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :close_file,
      describe: """
      Closes a file.

      Uses `File.close/1`.
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
          doc: "The IO device to close"
        ]
      ]
    }
end
