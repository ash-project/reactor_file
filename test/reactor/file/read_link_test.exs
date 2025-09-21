# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.ReadLinkTest do
  @moduledoc false
  use FileCase, async: true

  defmodule ReadLinkReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    read_link :link do
      path(input(:path))
    end

    return :link
  end

  test "when the path is a symlink it returns the path of the source", %{tmp_dir: tmp_dir} do
    source = lorem_file(tmp_dir)
    target = Path.join(tmp_dir, Faker.UUID.v4())
    File.ln_s!(source, target)

    assert ^source = Reactor.run!(ReadLinkReactor, %{path: target})
  end
end
