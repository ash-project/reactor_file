# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.WriteStatTest do
  @moduledoc false
  use FileCase, async: true

  describe "write_stat" do
    defmodule WriteStatReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :stat

      write_stat :write_stat do
        path(input(:path))
        stat(input(:stat))
      end
    end

    test "it can change the stat of a file", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)

      time =
        DateTime.utc_now()
        |> DateTime.add(3 + :rand.uniform(3), :minute)
        |> DateTime.to_unix(:second)

      File.touch!(file, time)
      stat = File.stat!(file, time: :posix)
      File.touch!(file)
      refute File.stat!(file, time: :posix).mtime == time

      Reactor.run!(WriteStatReactor, %{path: file, stat: stat})

      assert File.stat!(file, time: :posix).mtime == time
    end
  end

  describe "write_stat with undo" do
    defmodule WriteStatUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :stat

      write_stat :write_stat do
        path(input(:path))
        stat(input(:stat))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :write_stat
      end
    end

    test "when the reactor fails, the original stat is restored", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)

      time =
        DateTime.utc_now()
        |> DateTime.add(3 + :rand.uniform(3), :minute)
        |> DateTime.to_unix(:second)

      File.touch!(file, time)
      stat = File.stat!(file, time: :posix)
      File.touch!(file)
      original_mtime = File.stat!(file, time: :posix).mtime
      refute original_mtime == time

      assert {:error, error} = Reactor.run(WriteStatUndoReactor, %{path: file, stat: stat})
      assert Exception.message(error) =~ ~r/abort/

      assert File.stat!(file, time: :posix).mtime == original_mtime
    end
  end
end
