# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.IoBinstreamTest do
  @moduledoc false
  use FileCase, async: false

  describe "reading" do
    defmodule IoBinStreamReadReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path

      open_file :open_file do
        path(input(:path))
        modes([:read])
      end

      io_binstream :io_binstream do
        device(result(:open_file))
        line_or_bytes(:line)
      end

      step :content do
        argument :input, result(:io_binstream)
        run &{:ok, Enum.join(&1.input, "")}
      end

      return :content

      close_file :close_file do
        device(result(:open_file))
        wait_for :content
      end
    end

    test "it can read the file", %{tmp_dir: tmp_dir} do
      path = lorem_file(tmp_dir)
      content = File.read!(path)

      assert {:ok, ^content} =
               Reactor.run(IoBinStreamReadReactor, %{path: path}, %{}, async?: false)
    end
  end

  describe "writing" do
    defmodule IoBinStreamWriteReactor do
      @moduledoc false
      use Reactor, extensions: [Reactor.File]

      input :path
      input :content

      open_file :open_file do
        path(input(:path))
        modes([:write])
      end

      io_binstream :io_binstream do
        device(result(:open_file))
        line_or_bytes(:line)
      end

      step :write_content do
        argument :stream, result(:io_binstream)
        argument :content, input(:content)

        run &{:ok, Enum.into(&1.content, &1.stream)}
      end

      close_file :close_file do
        device(result(:open_file))
        wait_for :write_content
      end

      return :write_content
    end

    test "it can write the file", %{tmp_dir: tmp_dir} do
      path = Path.join(tmp_dir, Faker.UUID.v4())
      content = 3 |> Faker.Lorem.sentences() |> Enum.map(&"#{&1}\n")

      Reactor.run!(IoBinStreamWriteReactor, %{path: path, content: content}, %{}, async?: false)

      assert Enum.join(content, "") == File.read!(path)
    end
  end
end
