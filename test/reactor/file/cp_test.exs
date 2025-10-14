# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.CpTest do
  @moduledoc false
  use FileCase, async: true

  describe "cp" do
    defmodule CpReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :source
      input :target

      cp :copy do
        source input(:source)
        target(input(:target))
      end
    end

    test "it copies the file", %{tmp_dir: tmp_dir} do
      source_file = lorem_file(tmp_dir)
      target_file = Path.join(tmp_dir, Faker.UUID.v4())

      refute File.exists?(target_file)
      Reactor.run!(CpReactor, %{source: source_file, target: target_file})
      assert File.exists?(target_file)
      assert File.read!(source_file) == File.read!(target_file)
    end

    test "when the target file already exists, it overwrites it", %{tmp_dir: tmp_dir} do
      [source_file, target_file] = lorem_files(tmp_dir, how_many: 2)

      Reactor.run!(CpReactor, %{source: source_file, target: target_file})
      assert File.read!(source_file) == File.read!(target_file)
    end
  end

  describe "cp with overwrite disabled" do
    defmodule CpNoOverwriteReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :source
      input :target

      cp :copy do
        source input(:source)
        target(input(:target))
        overwrite?(false)
      end
    end

    test "when the target file doesn't exist, it copies the file", %{tmp_dir: tmp_dir} do
      source_file = lorem_file(tmp_dir)
      target_file = Path.join(tmp_dir, Faker.UUID.v4())

      refute File.exists?(target_file)
      Reactor.run!(CpNoOverwriteReactor, %{source: source_file, target: target_file})
      assert File.exists?(target_file)
      assert File.read!(source_file) == File.read!(target_file)
    end

    test "when the target file already exists, it fails", %{tmp_dir: tmp_dir} do
      [source_file, target_file] = lorem_files(tmp_dir, how_many: 2)

      assert {:error, error} =
               Reactor.run(CpNoOverwriteReactor, %{source: source_file, target: target_file})

      assert Exception.message(error) =~ "Overwrite"
    end
  end

  describe "cp with revert" do
    defmodule CpRevertReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :source
      input :target

      cp :copy do
        source input(:source)
        target(input(:target))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :copy
      end
    end

    test "it backs up and reverts to the original file", %{tmp_dir: tmp_dir} do
      [source_file, target_file] = lorem_files(tmp_dir, how_many: 2)
      original_content = File.read!(target_file)

      assert {:error, error} =
               Reactor.run(CpRevertReactor, %{source: source_file, target: target_file})

      assert File.read!(target_file) == original_content
      assert Exception.message(error) =~ "abort"
    end
  end
end
