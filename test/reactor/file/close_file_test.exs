# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.CloseFileTest do
  @moduledoc false
  use FileCase, async: true

  defmodule CloseFileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    open_file :open_file do
      path(input(:path))
      modes([:read])
    end

    close_file :close_file do
      device(result(:open_file))
    end

    return :close_file
  end

  test "it opens and closes the file", %{tmp_dir: tmp_dir} do
    path = lorem_file(tmp_dir)

    assert :ok = Reactor.run!(CloseFileReactor, %{path: path})
  end
end
