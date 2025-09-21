# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.StatTest do
  @moduledoc false
  use FileCase, async: true

  defmodule StatFileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    stat :stat do
      path(input(:path))
    end

    return :stat
  end

  test "when the file exists, it returns the stat struct", %{tmp_dir: tmp_dir} do
    file = lorem_file(tmp_dir)

    assert %File.Stat{} = Reactor.run!(StatFileReactor, %{path: file})
  end
end
