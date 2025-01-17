defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Glob do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(glob, reactor) do
    Builder.add_step(
      reactor,
      glob.name,
      {Reactor.File.Step.Glob, match_dot: glob.match_dot},
      [Argument.from_template(:pattern, glob.pattern) | glob.arguments],
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
