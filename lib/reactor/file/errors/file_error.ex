# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.FileError do
  @moduledoc """
  This exception is returned when a POSIX file error is returned by the standard
  library.
  """
  use Reactor.Error, fields: [:action, :step, :message, :file, :reason], class: :invalid
  import Reactor.Error.Utils

  @posix [
    :eacces,
    :eagain,
    :ebadf,
    :ebadmsg,
    :ebusy,
    :edeadlk,
    :edeadlock,
    :edquot,
    :eexist,
    :efault,
    :efbig,
    :eftype,
    :eintr,
    :einval,
    :eio,
    :eisdir,
    :eloop,
    :emfile,
    :emlink,
    :emultihop,
    :enametoolong,
    :enfile,
    :enobufs,
    :enodev,
    :enolck,
    :enolink,
    :enoent,
    :enomem,
    :enospc,
    :enosr,
    :enostr,
    :enosys,
    :enotblk,
    :enotdir,
    :enotsup,
    :enxio,
    :eopnotsupp,
    :eoverflow,
    :eperm,
    :epipe,
    :erange,
    :erofs,
    :espipe,
    :esrch,
    :estale,
    :etxtbsy,
    :exdev
  ]

  @doc "Is the atom a POSIX error?"
  @spec is_posix(atom) :: Macro.output()
  defguard is_posix(atom) when atom in @posix

  @doc false
  @impl true
  def message(error) do
    """
    # File Error

    #{@moduledoc}

    ## `message`

    #{describe_error(error.message)}

    ## `action`

    #{describe_error(error.action)}

    ## `reason`

    `#{inspect(error.reason)}`: #{:file.format_error(error.reason)}

    ## `file`

    #{describe_error(error.file)}

    ## `step`

    #{describe_error(error.step)}
    """
  end
end
