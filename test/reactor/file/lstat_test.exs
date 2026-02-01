# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.LstatTest do
  @moduledoc false
  use FileCase, async: true

  defmodule LstatFileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    lstat :stat do
      path(input(:path))
    end

    return :stat
  end

  test "when the path is a symlink it returns a link stat", %{tmp_dir: tmp_dir} do
    source = lorem_file(tmp_dir)
    target = Path.join(tmp_dir, Faker.UUID.v4())
    File.ln_s!(source, target)

    assert stat = Reactor.run!(LstatFileReactor, %{path: target})
    assert stat.type == :symlink
  end

  test "when the path is not a symlink, it returns the normal stat result", %{tmp_dir: tmp_dir} do
    target = lorem_file(tmp_dir)

    assert stat = Reactor.run!(LstatFileReactor, %{path: target})
    assert stat.type == :regular
  end
end
