defimpl Reactor.Dsl.Build, for: Reactor.File.Dsl.Rmdir do
  @moduledoc false
  alias Reactor.{Argument, Builder}

  @doc false
  def build(rmdir, reactor) do
    Builder.add_step(
      reactor,
      rmdir.name,
      {Reactor.File.Step.Rmdir, recreate_on_undo?: rmdir.recreate_on_undo?},
      [Argument.from_template(:path, rmdir.path) | rmdir.arguments],
      ref: :step_name
    )
  end

  @doc false
  def verify(_, _), do: :ok

  @doc false
  def transform(_, dsl_state), do: {:ok, dsl_state}
end
