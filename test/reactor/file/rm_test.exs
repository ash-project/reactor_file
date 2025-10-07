# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.RmTest do
  @moduledoc false
  use FileCase, async: true

  describe "rm" do
    defmodule RmReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path

      rm :rm do
        path(input(:path))
      end
    end

    test "when the path exists and is a file, it is removed", %{tmp_dir: tmp_dir} do
      path = lorem_file(tmp_dir)

      Reactor.run!(RmReactor, %{path: path})
      refute File.exists?(path)
    end
  end

  describe "rm with undo" do
    defmodule RmUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path

      rm :rm do
        path(input(:path))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :rm
      end
    end

    test "the file is recreated when the reactor fails", %{tmp_dir: tmp_dir} do
      path = lorem_file(tmp_dir)
      content = File.read!(path)

      assert {:error, error} = Reactor.run(RmUndoReactor, %{path: path})
      assert File.read!(path) == content
      assert Exception.message(error) =~ ~r/abort/
    end
  end
end
