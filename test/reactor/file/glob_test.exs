# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.GlobTest do
  @moduledoc false
  use FileCase, async: true

  defmodule NonDotfileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input(:pattern)

    glob :all_files do
      pattern(input(:pattern))
    end
  end

  defmodule DotfileReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input(:pattern)

    glob :all_files do
      pattern(input(:pattern))
      match_dot(true)
    end
  end

  test "it finds non dotfiles by default", %{tmp_dir: tmp_dir} do
    files = lorem_files(tmp_dir)

    assert files == Reactor.run!(NonDotfileReactor, %{pattern: Path.join(tmp_dir, "*")})
  end

  test "it doesn't find dotfiles by default", %{tmp_dir: tmp_dir} do
    lorem_files(tmp_dir, lorem_file_opts: [prefix: "."])

    assert [] == Reactor.run!(NonDotfileReactor, %{pattern: Path.join(tmp_dir, "*")})
  end

  test "it finds dotfiles when enabled", %{tmp_dir: tmp_dir} do
    files =
      lorem_files(tmp_dir)
      |> Enum.concat(lorem_files(tmp_dir, lorem_file_opts: [prefix: "."]))
      |> Enum.sort()

    assert files == Reactor.run!(DotfileReactor, %{pattern: Path.join(tmp_dir, "*")})
  end
end
