# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.CpRTest do
  @moduledoc false
  use FileCase, async: true

  describe "cp_r" do
    defmodule CpRReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :source
      input :target

      cp_r :copy do
        source input(:source)
        target(input(:target))
      end
    end

    test "when the source is a single file, it copies the file", %{tmp_dir: tmp_dir} do
      source_file = lorem_file(tmp_dir)
      target_file = Path.join(tmp_dir, Faker.UUID.v4())

      refute File.exists?(target_file)
      Reactor.run!(CpRReactor, %{source: source_file, target: target_file})
      assert File.exists?(target_file)
      assert File.read!(source_file) == File.read!(target_file)
    end

    test "when the source and target are directories, it copies recursively", %{tmp_dir: tmp_dir} do
      source_dir = Path.join(tmp_dir, Faker.UUID.v4())
      File.mkdir_p!(source_dir)
      source_files = lorem_files(source_dir, how_many: 3)

      target_dir = Path.join(tmp_dir, Faker.UUID.v4())

      refute File.exists?(target_dir)
      Reactor.run!(CpRReactor, %{source: source_dir, target: target_dir})

      assert File.dir?(target_dir)

      for source_file <- source_files do
        target_file =
          source_file
          |> Path.basename()
          |> then(&Path.join(target_dir, &1))

        assert File.read!(source_file) == File.read!(target_file)
      end
    end
  end

  describe "cp_r with revert" do
    defmodule CpRRevertReactor do
      @moduledoc false
      alias Reactor.File.CpRTest.CpRReactor
      use Reactor, extensions: [Reactor.File]

      input :source
      input :target

      cp_r :copy do
        source input(:source)
        target(input(:target))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :copy
      end
    end

    test "it backs up and reverts the original directory", %{tmp_dir: tmp_dir} do
      source_dir = Path.join(tmp_dir, Faker.UUID.v4())
      File.mkdir_p!(source_dir)
      lorem_files(source_dir, how_many: 3)

      target_dir = Path.join(tmp_dir, Faker.UUID.v4())
      File.mkdir_p!(target_dir)

      existing_target_files = lorem_files(target_dir, how_many: 3)

      assert {:error, error} =
               Reactor.run(CpRRevertReactor, %{source: source_dir, target: target_dir})

      assert Path.wildcard("#{target_dir}/*") == existing_target_files
      assert Exception.message(error) =~ "abort"
    end
  end
end
