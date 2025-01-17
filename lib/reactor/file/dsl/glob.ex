defmodule Reactor.File.Dsl.Glob do
  @moduledoc """
  A `glob` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.WaitFor, Template}

  defstruct __identifier__: nil, description: nil, name: nil, pattern: nil, match_dot: false

  @type t :: %__MODULE__{
          __identifier__: any,
          description: nil | String.t(),
          name: any,
          pattern: Template.t(),
          match_dot: boolean
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :glob,
      describe: """
      Searches for files matching the provided pattern.

      Uses `Path.wildcard/2` under the hood.
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
        pattern: [
          type: Template.type(),
          required: true,
          doc: "A pattern used to select files. See `Path.wildcard/2` for more information."
        ],
        match_dot: [
          type: :boolean,
          required: false,
          default: false,
          doc:
            "Whether or not files starting with a `.` will be matched by the pattern. See `Path.wildcard/2` for more information."
        ]
      ]
    }
end
