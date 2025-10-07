# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.OverwriteError do
  @moduledoc """
  This exception is returned when a step would otherwise overwritten data
  without permission.
  """
  use Reactor.Error, fields: [:step, :message, :file], class: :invalid
  import Reactor.Error.Utils

  @doc false
  @impl true
  def message(error) do
    """
    # Overwrite Error

    #{@moduledoc}

    ## `message`

    #{describe_error(error.message)}

    ## `step`

    #{describe_error(error.step)}

    ## `file`

    #{describe_error(error.file)}
    """
  end
end
