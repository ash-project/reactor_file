defmodule Reactor.File.WriteStatTest do
  @moduledoc false
  use FileCase, async: true

  describe "write_stat" do
    defmodule WriteStatReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :stat

      write_stat :write_stat do
        path(input(:path))
        stat(input(:stat))
      end
    end

    test "it can change the stat of a file", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)

      time =
        DateTime.utc_now()
        |> DateTime.add(3 + :rand.uniform(3), :minute)
        |> DateTime.to_unix(:second)

      File.touch!(file, time)
      stat = File.stat!(file, time: :posix)
      File.touch!(file)
      refute File.stat!(file, time: :posix).mtime == time

      Reactor.run!(WriteStatReactor, %{path: file, stat: stat})

      assert File.stat!(file, time: :posix).mtime == time
    end
  end
end
