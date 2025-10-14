# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.MkdirPTest do
  @moduledoc false
  use FileCase, async: true

  describe "mkdir_p" do
    defmodule MkdirPReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input(:path)

      mkdir_p :some_dir do
        path(input(:path))
      end
    end

    test "when the parent path exists, it creates the directory", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "some_dir")

      refute File.exists?(path)
      Reactor.run!(MkdirPReactor, %{path: path})
      assert File.dir?(path)
    end

    test "when the parent path does not exist, it creates all the required directories", %{
      tmp_dir: tmp_dir
    } do
      path = Path.join([tmp_dir, "a", "b", "c", "d"])

      refute File.exists?(path)
      Reactor.run!(MkdirPReactor, %{path: path})
      assert File.dir?(path)
    end
  end

  describe "mkdir_p with undo" do
    defmodule MkdirPWithUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input(:path)

      mkdir_p :some_dir do
        path(input(:path))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for(:some_dir)
      end
    end

    test "when the reactor fails, it removes the directory", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "some_dir")

      refute File.exists?(path)
      assert {:error, error} = Reactor.run(MkdirPWithUndoReactor, %{path: path})
      refute File.exists?(path)
      assert Exception.message(error) =~ ~r/abort/
    end

    test "when the parent path does not exist, it removes all the created directories", %{
      tmp_dir: tmp_dir
    } do
      path = Path.join([tmp_dir, "a", "b", "c", "d"])

      refute File.exists?(path)
      assert {:error, error} = Reactor.run(MkdirPWithUndoReactor, %{path: path})
      refute File.dir?(Path.join(tmp_dir, "a"))
      assert Exception.message(error) =~ ~r/abort/
    end
  end
end
