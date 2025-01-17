defmodule Reactor.File.ChownTest do
  @moduledoc false
  use FileCase, async: true

  if System.get_env("CI") do
    @target_uid %{
      {:unix, :darwin} => 99,
      {:unix, :linux} => 65_534
    }

    describe "chown" do
      defmodule ChownReactor do
        @moduledoc false
        use Reactor, extensions: [Reactor.File]

        input :path
        input :uid

        chown :chown do
          path(input(:path))
          uid(input(:uid))
        end
      end

      test "it can change the UID of a file", %{tmp_dir: tmp_dir} do
        file = lorem_file(tmp_dir)

        %{uid: original_uid} = File.stat!(file)
        new_uid = Map.fetch!(@target_uid, :os.type())
        assert new_uid != original_uid

        Reactor.run!(ChownReactor, %{path: file, uid: new_uid})

        assert %{uid: ^new_uid} = File.stat!(file)
      end
    end

    describe "chown with undo" do
      defmodule ChownUndoReactor do
        @moduledoc false
        use Reactor, extensions: [Reactor.File]

        input :path
        input :uid

        chown :chown do
          path(input(:path))
          uid(input(:uid))
          revert_on_undo?(true)
        end

        flunk :fail, "abort" do
          wait_for :chown
        end
      end

      test "it can revert the UID back to the original value on undo", %{tmp_dir: tmp_dir} do
        file = lorem_file(tmp_dir)

        %{uid: original_uid} = File.stat!(file)
        new_uid = Map.fetch!(@target_uid, :os.type())
        assert new_uid != original_uid

        assert {:error, error} = Reactor.run(ChownUndoReactor, %{path: file, uid: new_uid})

        assert %{uid: ^original_uid} = File.stat!(file)
        assert Exception.message(error) =~ ~r/abort/
      end
    end
  end
end
