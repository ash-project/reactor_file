defmodule Reactor.File.Ops do
  @moduledoc false

  alias Reactor.File.{FileError, MissingMiddlewareError}
  require Reactor.File.FileError

  @doc "An error wrapped version of `File.chgrp/2`"
  def chgrp(path, gid, step, message \\ "Unable to change group") do
    with {:error, reason} when FileError.is_posix(reason) <- File.chgrp(path, gid) do
      {:error,
       FileError.exception(
         action: :chgrp,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.chmod/2`"
  def chmod(path, mode, step, message \\ "Unable to change permissions") do
    with {:error, reason} when FileError.is_posix(reason) <- File.chmod(path, mode) do
      {:error,
       FileError.exception(
         action: :chmod,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.chown/2`"
  def chown(path, uid, step, message \\ "Unable to change owner") do
    with {:error, reason} when FileError.is_posix(reason) <- File.chown(path, uid) do
      {:error,
       FileError.exception(
         action: :chown,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.cp/2`"
  def cp(source_path, destination_path, step, message \\ "Unable to copy file") do
    with {:error, reason} when FileError.is_posix(reason) <-
           File.cp(source_path, destination_path) do
      {:error,
       FileError.exception(
         action: {:cp, source_path, destination_path},
         step: step,
         message: message,
         file: destination_path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.cp/2`"
  def cp_r(source_path, destination_path, options, step, message \\ "Unable to copy file") do
    case File.cp_r(source_path, destination_path, options) do
      {:ok, _} ->
        :ok

      {:error, reason, fail_path} when FileError.is_posix(reason) ->
        {:error,
         FileError.exception(
           action: {:cp_r, source_path, destination_path},
           step: step,
           message: message,
           file: fail_path,
           reason: reason
         )}
    end
  end

  @doc "An error wrapped version of `File.ln/2`"
  def ln(existing, new, step, message \\ "Unable to create hard link") do
    with {:error, reason} when FileError.is_posix(reason) <-
           File.ln(existing, new) do
      {:error,
       FileError.exception(
         action: {:ln, existing, new},
         step: step,
         message: message,
         file: new,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.ln_s/2`"
  def ln_s(existing, new, step, message \\ "Unable to create symbolic link") do
    with {:error, reason} when FileError.is_posix(reason) <-
           File.ln_s(existing, new) do
      {:error,
       FileError.exception(
         action: {:ln_s, existing, new},
         step: step,
         message: message,
         file: new,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.lstat/2`"
  def lstat(path, opts, step, message \\ "Unable to retrieve file information") do
    with {:error, reason} when FileError.is_posix(reason) <- File.lstat(path, opts) do
      {:error,
       FileError.exception(
         action: :lstat,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.mkdir/1`"
  def mkdir(path, step, message \\ "Unable to create directory") do
    with {:error, reason} when FileError.is_posix(reason) <- File.mkdir(path) do
      {:error,
       FileError.exception(
         action: :mkdir,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.mkdir_p/1`"
  def mkdir_p(path, step, message \\ "Unable to create directory") do
    with {:error, reason} when FileError.is_posix(reason) <- File.mkdir_p(path) do
      {:error,
       FileError.exception(
         action: :mkdir_p,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.lstat/2`"
  def read_link(path, step, message \\ "Unable to read link") do
    with {:error, reason} when FileError.is_posix(reason) <- File.read_link(path) do
      {:error,
       FileError.exception(
         action: :read_link,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.rmdir/1`"
  def rmdir(path, step, message \\ "Unable to remove directory") do
    with {:error, reason} when FileError.is_posix(reason) <- File.rmdir(path) do
      {:error,
       FileError.exception(
         action: :rmdir,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.rm_rf/1`"
  def rm_rf(path, step, message \\ "Unable to recursively delete") do
    case File.rm_rf(path) do
      {:ok, _} ->
        :ok

      {:error, reason, fail_path} when FileError.is_posix(reason) ->
        {:error,
         FileError.exception(
           action: {:rm_rf, path},
           step: step,
           message: message,
           file: fail_path,
           reason: reason
         )}

      {:error, reason, _} ->
        {:error, reason}
    end
  end

  @doc "An error wrapped version of `File.rm/1`"
  def rm(path, step, message \\ "Unable to delete file") do
    with {:error, reason} when FileError.is_posix(reason) <- File.rm(path) do
      {:error,
       FileError.exception(
         action: :rm,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.stat/2`"
  def stat(path, opts, step, message \\ "Unable to retrieve file information") do
    with {:error, reason} when FileError.is_posix(reason) <- File.stat(path, opts) do
      {:error,
       FileError.exception(
         action: :stat,
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "An error wrapped version of `File.write_stat/2`"
  def write_stat(path, stat, opts, step, message \\ "Unable to write file information") do
    with {:error, reason} when FileError.is_posix(reason) <- File.write_stat(path, stat, opts) do
      {:error,
       FileError.exception(
         action: {:write_stat, stat},
         step: step,
         message: message,
         file: path,
         reason: reason
       )}
    end
  end

  @doc "A stat which doesn't fail when the file doesn't exist"
  def maybe_stat(path, opts, step, message \\ "Unable to retrieve file information") do
    if File.exists?(path) do
      stat(path, opts, step, message)
    else
      {:ok, nil}
    end
  end

  @doc "Places a copy of a file into the undo stash"
  def backup_file(path, context, message \\ "Unable to backup file")

  def backup_file(path, %{Reactor.File.Middleware => %{tmp_dir: tmp_dir}} = context, message) do
    backup_file_name = {context.current_step, path} |> :erlang.phash2() |> Integer.to_string(16)
    backup_path = Path.join(tmp_dir, backup_file_name)

    with :ok <- cp(path, backup_path, message) do
      {:ok, backup_path}
    end
  end

  def backup_file(_path, context, message),
    do: {:error, MissingMiddlewareError.exception(message: message, step: context.current_step)}

  @doc "Places a copy of a directory into the undo stash"
  def backup_dir(path, context, message \\ "Unable to backup dir")

  def backup_dir(path, %{Reactor.File.Middleware => %{tmp_dir: tmp_dir}} = context, message) do
    backup_dir_name = {context.current_step, path} |> :erlang.phash2() |> Integer.to_string(16)
    backup_path = Path.join(tmp_dir, backup_dir_name)

    with :ok <- mkdir_p(backup_path, context.current_step, message),
         :ok <- cp_r(path, backup_path, [], context.current_step, message) do
      {:ok, backup_path}
    end
  end
end
