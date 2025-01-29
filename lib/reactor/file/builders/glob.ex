defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Glob do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(step, reactor) do
    Builder.add_step(
      reactor,
      step.name,
      {Reactor.File.Step.Glob, match_dot: step.match_dot},
      [Argument.from_template(:pattern, step.pattern) | step.arguments],
      guards: step.guards,
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
