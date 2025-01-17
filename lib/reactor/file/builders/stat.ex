defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Stat do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(stat, reactor) do
    Builder.add_step(
      reactor,
      stat.name,
      {Reactor.File.Step.Stat, time: stat.time},
      [Argument.from_template(:path, stat.path) | stat.arguments],
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
