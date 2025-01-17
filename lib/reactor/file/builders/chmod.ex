defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Chmod do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(step, reactor) do
    arguments =
      step.arguments
      |> Enum.concat([
        Argument.from_template(:mode, step.mode),
        Argument.from_template(:path, step.path)
      ])

    Builder.add_step(
      reactor,
      step.name,
      {Reactor.File.Step.Chmod, revert_on_undo?: step.revert_on_undo?},
      arguments,
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
