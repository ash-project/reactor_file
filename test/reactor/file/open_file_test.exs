# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.OpenFileTest do
  @moduledoc false
  use FileCase, async: false

  defmodule OpenFileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    open_file :open_file do
      path(input(:path))
      modes([:read])
    end

    return :open_file
  end

  test "when the file exists, it opens it", %{tmp_dir: tmp_dir} do
    path = lorem_file(tmp_dir)
    content = File.read!(path)

    assert {:ok, file} = Reactor.run(OpenFileReactor, %{path: path}, %{}, async?: false)
    assert ^content = IO.read(file, :eof)
  end
end
