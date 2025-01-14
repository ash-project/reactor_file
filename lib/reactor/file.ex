defmodule Reactor.File do
  @moduledoc """
  An extension which provides steps for working with the local filesystem within Reactor.
  """

  use Spark.Dsl.Extension,
    dsl_patches:
      [
        Reactor.File.Dsl.Glob
      ]
      |> Enum.map(
        &%Spark.Dsl.Patch.AddEntity{
          section_path: [:reactor],
          entity: &1.__entity__()
        }
      )
end
