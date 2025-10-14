# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.MissingMiddlewareError do
  @moduledoc """
  This exception is returned when a step wishes to temporarily store files but
  the `Reactor.File.Middleware` middleware has not been added to the reactor.
  """
  use Reactor.Error, fields: [:step, :message], class: :invalid
  import Reactor.Error.Utils

  @doc false
  @impl true
  def message(error) do
    """
    # Missing Middleware Error

    #{@moduledoc}

    ## `message`

    #{describe_error(error.message)}

    ## `step`

    #{describe_error(error.step)}
    """
  end
end
