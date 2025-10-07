# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.MkdirTest do
  @moduledoc false
  use FileCase, async: true

  describe "mkdir" do
    defmodule MkdirReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input(:path)

      mkdir :some_dir do
        path(input(:path))
      end
    end

    test "when the parent path exists, it creates the directory", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "some_dir")

      refute File.exists?(path)
      Reactor.run!(MkdirReactor, %{path: path})
      assert File.dir?(path)
    end

    test "when the parent path does not exists, it fails", %{tmp_dir: tmp_dir} do
      path = Path.join([tmp_dir, "a", "b", "c"])

      refute File.exists?(path)

      assert_raise Reactor.Error.Invalid, ~r/:enoent/, fn ->
        Reactor.run!(MkdirReactor, %{path: path})
      end
    end
  end

  describe "mkdir with undo" do
    defmodule MkdirWithUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input(:path)

      mkdir :some_dir do
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
      assert {:error, error} = Reactor.run(MkdirWithUndoReactor, %{path: path})
      refute File.exists?(path)
      assert Exception.message(error) =~ ~r/abort/
    end
  end
end
