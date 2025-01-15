defmodule Reactor.File.RmdirTest do
  @moduledoc false
  use FileCase, async: true

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
