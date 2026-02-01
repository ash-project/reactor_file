# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Cp do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(step, reactor) do
    arguments =
      step.arguments
      |> Enum.concat([
        Argument.from_template(:source, step.source),
        Argument.from_template(:target, step.target)
      ])

    Builder.add_step(
      reactor,
      step.name,
      {Reactor.File.Step.Cp, overwrite?: step.overwrite?, revert_on_undo?: step.revert_on_undo?},
      arguments,
      guards: step.guards,
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
