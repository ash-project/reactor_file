# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.LnSTest do
  @moduledoc false
  use FileCase, async: true

  describe "ln" do
    defmodule LnSReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :existing
      input :new

      ln_s :link do
        existing(input(:existing))
        new(input(:new))
      end
    end

    test "when the new file doesn't exist, it links the file", %{tmp_dir: tmp_dir} do
      existing_file = lorem_file(tmp_dir)
      new_file = Path.join(tmp_dir, Faker.UUID.v4())

      refute File.exists?(new_file)
      Reactor.run!(LnSReactor, %{existing: existing_file, new: new_file})
      assert File.read_link!(new_file) == existing_file
    end

    test "when the new file already exists, it overwrites it", %{tmp_dir: tmp_dir} do
      [existing_file, new_file] = lorem_files(tmp_dir, how_many: 2)

      Reactor.run!(LnSReactor, %{existing: existing_file, new: new_file})
      assert File.read_link!(new_file) == existing_file
    end
  end

  describe "ln with overwrite disabled" do
    defmodule LnSNoOverwriteReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :existing
      input :new

      ln_s :link do
        existing(input(:existing))
        new(input(:new))
        overwrite?(false)
      end
    end

    test "when the target file doesn't exist, it creates the link", %{tmp_dir: tmp_dir} do
      existing_file = lorem_file(tmp_dir)
      new_file = Path.join(tmp_dir, Faker.UUID.v4())

      refute File.exists?(new_file)
      Reactor.run!(LnSNoOverwriteReactor, %{existing: existing_file, new: new_file})
      assert File.read_link!(new_file) == existing_file
    end

    test "when the target file already exists, it fails", %{tmp_dir: tmp_dir} do
      [existing_file, new_file] = lorem_files(tmp_dir, how_many: 2)

      assert {:error, error} =
               Reactor.run(LnSNoOverwriteReactor, %{existing: existing_file, new: new_file})

      assert Exception.message(error) =~ "Overwrite"
    end
  end

  describe "ln with revert" do
    defmodule LnSRevertReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :existing
      input :new

      ln_s :link do
        existing(input(:existing))
        new(input(:new))
        revert_on_undo?(true)
      end

      flunk :fail, "abort" do
        wait_for :link
      end
    end

    test "it backs up and reverts the original file", %{tmp_dir: tmp_dir} do
      [existing_file, new_file] = lorem_files(tmp_dir, how_many: 2)
      File.chmod!(existing_file, 0o600)
      File.chmod!(new_file, 0o666)
      existing_content = File.read!(existing_file)
      original_content = File.read!(new_file)

      assert {:error, error} =
               Reactor.run(LnSRevertReactor, %{existing: existing_file, new: new_file})

      assert Exception.message(error) =~ "abort"

      assert File.read!(existing_file) == existing_content
      assert Bitwise.band(File.stat!(existing_file).mode, 0o777) == 0o600

      assert %{type: :regular, mode: new_mode} = File.lstat!(new_file)
      assert Bitwise.band(new_mode, 0o777) == 0o666
      assert File.read!(new_file) == original_content
    end

    test "when the new file didn't exist, it removes the link", %{tmp_dir: tmp_dir} do
      existing_file = lorem_file(tmp_dir)
      existing_content = File.read!(existing_file)
      new_file = Path.join(tmp_dir, Faker.UUID.v4())

      assert {:error, error} =
               Reactor.run(LnSRevertReactor, %{existing: existing_file, new: new_file})

      assert Exception.message(error) =~ "abort"

      assert {:error, :enoent} = File.lstat(new_file)
      assert File.read!(existing_file) == existing_content
    end
  end
end
