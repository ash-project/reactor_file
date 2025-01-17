defmodule Reactor.File.Middleware do
  @moduledoc """
  A Reactor middleware which provides a temporary storage space for files during
  undo operations.
  """
  use Reactor.Middleware

  @doc false
  @impl true
  def init(context) do
    chunk =
      {Node.self(), System.pid(), self()}
      |> :erlang.phash2()
      |> Integer.to_string(16)

    tmp_dir =
      System.tmp_dir!()
      |> Path.join(chunk)

    with :ok <- File.mkdir(tmp_dir) do
      {:ok, Map.put(context, __MODULE__, %{tmp_dir: tmp_dir})}
    end
  end

  @doc false
  @impl true
  def complete(result, %{__MODULE__ => %{tmp_dir: tmp_dir}}) do
    File.rm_rf!(tmp_dir)

    {:ok, result}
  end

  @doc false
  @impl true
  def error(_errors, %{__MODULE__ => %{tmp_dir: tmp_dir}}) do
    File.rm_rf!(tmp_dir)

    :ok
  end
end
