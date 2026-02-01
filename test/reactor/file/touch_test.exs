# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.TouchTest do
  @moduledoc false
  use FileCase, async: true

  defmodule TouchReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path
    input :time

    touch :touch do
      path(input(:path))
      time(input(:time))
    end

    return :touch
  end

  test "when the file doesn't exist, it creates it and sets the time", %{tmp_dir: tmp_dir} do
    file = Path.join(tmp_dir, "example")

    time =
      DateTime.utc_now()
      |> DateTime.add(3 + :rand.uniform(3), :minute)
      |> DateTime.to_unix(:second)

    Reactor.run!(TouchReactor, %{path: file, time: time})

    assert File.stat!(file, time: :posix).mtime == time
  end

  test "when the file does exist, it updates the mtime and atime", %{tmp_dir: tmp_dir} do
    file = lorem_file(tmp_dir)

    time =
      DateTime.utc_now()
      |> DateTime.add(3 + :rand.uniform(3), :minute)
      |> DateTime.to_unix(:second)

    refute File.stat!(file, time: :posix).mtime == time

    Reactor.run!(TouchReactor, %{path: file, time: time})

    assert File.stat!(file, time: :posix).mtime == time
  end
end
