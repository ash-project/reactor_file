defmodule Reactor.File.Dsl.WriteStat do
  @moduledoc """
  A `write_stat` DSL entity for the `Reactor.File` DSL extension.
  """
  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            guards: [],
            name: nil,
            path: nil,
            revert_on_undo?: false,
            stat: nil,
            time: :posix

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          path: Template.t(),
          revert_on_undo?: boolean,
          stat: Template.t(),
          time: :universal | :local | :posix
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :write_stat,
      describe: """
      Writes the given `File.Stat` back to the filesystem at the given path.
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
          doc: "The path to the file to modify"
        ],
        stat: [
          type: Template.type(),
          required: true,
          doc: "The stat to write"
        ],
        revert_on_undo?: [
          type: :boolean,
          required: false,
          default: false,
          doc: "Revert to the original state when undoing changes"
        ],
        time: [
          type: {:in, [:universal, :local, :posix]},
          required: false,
          default: :posix,
          doc: "What format to return the file times in. See `File.stat/2` for more."
        ]
      ]
    }
end
