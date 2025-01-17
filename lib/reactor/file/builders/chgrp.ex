defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Chgrp do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(stat, reactor) do
    arguments =
      stat.arguments
      |> Enum.concat([
        Argument.from_template(:gid, stat.gid),
        Argument.from_template(:path, stat.path)
      ])

    Builder.add_step(
      reactor,
      stat.name,
      {Reactor.File.Step.Chgrp, revert_on_undo?: stat.revert_on_undo?},
      arguments,
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
