# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

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
      {Node.self(), System.pid(), self(), context.__reactor__.id}
      |> :erlang.phash2()
      |> Integer.to_string(16)

    tmp_dir =
      System.tmp_dir!()
      |> Path.join(chunk)

    with {:ok, tmp_dir} <- make_tmp_dir(tmp_dir) do
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

  defp make_tmp_dir(tmp_dir, id \\ 0) do
    path = "#{tmp_dir}_#{id}"

    if File.dir?(path) do
      make_tmp_dir(tmp_dir, id + 1)
    else
      with :ok <- File.mkdir(path) do
        {:ok, path}
      end
    end
  end
end
