defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.IoStream do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(step, reactor) do
    Builder.add_step(
      reactor,
      step.name,
      {Reactor.File.Step.IoStream, line_or_codepoints: step.line_or_codepoints},
      [Argument.from_template(:device, step.device) | step.arguments],
      guards: step.guards,
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
