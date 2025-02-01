defmodule Reactor.File.WriteFileTest do
  @moduledoc false
  use FileCase, async: true

  describe "write_file" do
    defmodule WriteFileReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :content

      write_file :write_file do
        path(input(:path))
        content(input(:content))
        modes([:utf8])
      end
    end

    test "when the file exists it overwrites it", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)
      new_content = Faker.Lorem.sentence()
      Reactor.run!(WriteFileReactor, %{path: file, content: new_content})
      assert File.read!(file) == new_content
    end
  end

  describe "write_file with undo" do
    defmodule WriteFileUndoReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :content

      write_file :write_file do
        path(input(:path))
        content(input(:content))
        modes([:utf8])
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :write_file
      end
    end

    test "when the reactor fails it reverts back to the original content", %{tmp_dir: tmp_dir} do
      file = lorem_file(tmp_dir)
      original_content = File.read!(file)
      new_content = Faker.Lorem.sentence()

      assert {:error, error} =
               Reactor.run(WriteFileUndoReactor, %{path: file, content: new_content})

      assert File.read!(file) == original_content
      assert Exception.message(error) =~ ~r/abort/
    end
  end
end
