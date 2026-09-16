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

  describe "touch with undo" do
    defmodule TouchUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :time

      touch :touch do
        path(input(:path))
        time(input(:time))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :touch
      end
    end

    test "when the file didn't exist, it is removed", %{tmp_dir: tmp_dir} do
      file = Path.join(tmp_dir, "example")

      time =
        DateTime.utc_now()
        |> DateTime.add(3 + :rand.uniform(3), :minute)
        |> DateTime.to_unix(:second)

      assert {:error, error} = Reactor.run(TouchUndoReactor, %{path: file, time: time})
      assert Exception.message(error) =~ ~r/abort/

      refute File.exists?(file)
    end

    test "when the file did exist, its mtime is restored", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)
      original_mtime = File.stat!(file, time: :posix).mtime

      time =
        DateTime.utc_now()
        |> DateTime.add(3 + :rand.uniform(3), :minute)
        |> DateTime.to_unix(:second)

      assert {:error, error} = Reactor.run(TouchUndoReactor, %{path: file, time: time})
      assert Exception.message(error) =~ ~r/abort/

      assert File.stat!(file, time: :posix).mtime == original_mtime
    end
  end
end
