# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.ReadFileTest do
  @moduledoc false
  use FileCase, async: true

  defmodule ReadFileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    read_file :read_file do
      path(input(:path))
    end

    return :read_file
  end

  test "when the path exists, it reads the file", %{tmp_dir: tmp_dir} do
    file = lorem_file(tmp_dir)
    content = File.read!(file)

    assert ^content = Reactor.run!(ReadFileReactor, %{path: file})
  end
end
