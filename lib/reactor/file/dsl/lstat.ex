# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Dsl.Lstat do
  @moduledoc """
  A `stat` DSL entity for the `Reactor.File` DSL extension.
  """

  alias Reactor.{Dsl.Argument, Dsl.Guard, Dsl.WaitFor, Dsl.Where, Template}

  defstruct __identifier__: nil,
            arguments: [],
            description: nil,
            guards: [],
            name: nil,
            path: nil,
            time: :posix

  @type t :: %__MODULE__{
          __identifier__: any,
          arguments: [Argument.t()],
          description: nil | String.t(),
          guards: [Reactor.Guard.Build.t()],
          name: any,
          path: Template.t(),
          time: :universal | :local | :posix
        }

  @doc false
  def __entity__,
    do: %Spark.Dsl.Entity{
      name: :lstat,
      describe: """
      Returns information about a path.

      If the file is a symlink, sets the type to `:symlink` and returns a
      `File.Stat` struct for the link. For any other file, returns exactly the
      same values as `stat`.

      See `File.lstat/2` for more information.
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
          doc: "The path of the directory to create"
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
