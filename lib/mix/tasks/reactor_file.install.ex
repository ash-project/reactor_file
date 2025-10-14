# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.ReactorFile.Install do
    @moduledoc """
    Installs Reactor.File into a project.  Should be called with `mix igniter.install reactor_file`.
    """

    alias Igniter.{Mix.Task, Project.Formatter}

    use Task

    @doc false
    @impl Task
    def igniter(igniter) do
      igniter
      |> Formatter.import_dep(:reactor_file)
    end
  end
else
  defmodule Mix.Tasks.ReactorFile.Install do
    @moduledoc """
    Installs Reactor.File into a project.  Should be called with `mix igniter.install reactor_file`.
    """

    use Mix.Task

    def run(_argv) do
      Mix.shell().error("""
      The task 'reactor_file.install' requires igniter to be run.

      Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter
      """)

      exit({:shutdown, 1})
    end
  end
end
