defmodule Reactor.File.RmdirTest do
  @moduledoc false
  use FileCase, async: true

  describe "rmdir" do
    defmodule RmdirReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input(:path)

      rmdir :some_dir do
        path(input(:path))
      end
    end

    test "when the path exists and is empty, it can be removed", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "some_dir")

      File.mkdir!(path)
      Reactor.run!(RmdirReactor, %{path: path})
      refute File.exists?(path)
    end
  end

  describe "rmdir with undo" do
    defmodule RmdirUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input(:path)

      rmdir :some_dir do
        path(input(:path))
        recreate_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for(:some_dir)
      end
    end

    test "the directory is recreated when the reactor fails", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, "some_dir")

      File.mkdir!(path)

      assert {:error, error} = Reactor.run(RmdirUndoReactor, %{path: path})
      assert File.dir?(path)
      assert Exception.message(error) =~ ~r/abort/
    end
  end
end
