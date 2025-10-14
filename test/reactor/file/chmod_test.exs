# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.ChmodTest do
  @moduledoc false
  use FileCase, async: true

  describe "chmod" do
    defmodule ChmodReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :mode

      chmod :chmod do
        path(input(:path))
        mode(input(:mode))
      end
    end

    test "it can change the mode of a file", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)

      original_mode = 0o666
      new_mode = 0o644

      File.chmod!(file, original_mode)

      Reactor.run!(ChmodReactor, %{path: file, mode: new_mode})

      assert %{mode: actual_mode} = File.stat!(file)
      assert new_mode == Bitwise.band(actual_mode, 0o777)
    end
  end

  describe "chmod with undo" do
    defmodule ChmodUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :mode

      chmod :chmod do
        path(input(:path))
        mode(input(:mode))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :chmod
      end
    end

    test "when the reactor fails, it can revert the file mode", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)

      original_mode = 0o666
      new_mode = 0o644

      File.chmod!(file, original_mode)

      assert {:error, error} = Reactor.run(ChmodUndoReactor, %{path: file, mode: new_mode})
      assert Exception.message(error) =~ ~r/abort/

      assert %{mode: actual_mode} = File.stat!(file)
      assert original_mode == Bitwise.band(actual_mode, 0o777)
    end
  end
end
