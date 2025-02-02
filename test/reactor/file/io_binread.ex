defmodule Reactor.File.IoBinReadTest do
  @moduledoc false
  use FileCase, async: true

  defmodule IoBinReadReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path

    open_file :open_file do
      path(input(:path))
      modes([:read])
    end

    io_binread :read_file do
      device(result(:open_file))
      line_or_chars(:eof)
    end

    close_file :close_file do
      wait_for :read_file
      device(result(:open_file))
    end

    return :read_file
  end

  test "it reads the content of the file", %{tmp_dir: tmp_dir} do
    path = lorem_file(tmp_dir)
    content = File.read!(path)

    assert ^content = Reactor.run!(IoBinReadReactor, %{path: path}, %{}, async?: false)
  end
end
