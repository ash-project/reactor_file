defmodule Reactor.File.ChgrpTest do
  @moduledoc false
  use FileCase, async: true

  if System.get_env("CI") do
    @target_gid %{
      {:unix, :darwin} => 12,
      {:unix, :linux} => 100
    }

    describe "chgrp" do
      defmodule ChgrpReactor do
        @moduledoc false
        use Reactor, extensions: [Reactor.File]

        input :path
        input :gid

        chgrp :chgrp do
          path(input(:path))
          gid(input(:gid))
        end
      end

      test "it can change the GID of a file", %{tmp_dir: tmp_dir} do
        file = lorem_file(tmp_dir)

        %{gid: original_gid} = File.stat!(file)
        new_gid = Map.fetch!(@target_gid, :os.type())
        assert new_gid != original_gid

        Reactor.run!(ChgrpReactor, %{path: file, gid: new_gid})

        assert %{gid: ^new_gid} = File.stat!(file)
      end
    end

    describe "chgrp with undo" do
      defmodule ChgrpUndoReactor do
        @moduledoc false
        use Reactor, extensions: [Reactor.File]

        input :path
        input :gid

        chgrp :chgrp do
          path(input(:path))
          gid(input(:gid))
          revert_on_undo?(true)
        end

        flunk :fail, "abort" do
          wait_for :chgrp
        end
      end

      test "it can revert the GID back to the original value on undo", %{tmp_dir: tmp_dir} do
        file = lorem_file(tmp_dir)

        %{gid: original_gid} = File.stat!(file)
        new_gid = Map.fetch!(@target_gid, :os.type())
        assert new_gid != original_gid

        assert {:error, error} = Reactor.run(ChgrpUndoReactor, %{path: file, gid: new_gid})

        assert %{gid: ^original_gid} = File.stat!(file)
        assert Exception.message(error) =~ ~r/abort/
      end
    end
  end
end
