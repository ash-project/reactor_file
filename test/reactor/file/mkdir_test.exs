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
end
