defmodule Reactor.File.IoWriteTest do
  @moduledoc false
  use FileCase, async: true

  defmodule IoWriteReactor do
    @moduledoc false
    use Reactor, extensions: [Reactor.File]

    input :path
    input :content

    open_file :open_file do
      path(input(:path))
      modes([:write])
    end

    io_write :io_write do
      device(result(:open_file))
      chardata(input(:content))
    end

    close_file :close_file do
      device(result(:open_file))
      wait_for :io_write
    end

    return :close_file
  end

  test "it writes the content to the file", %{tmp_dir: tmp_dir} do
    path = Path.join(tmp_dir, Faker.UUID.v4())
    content = Faker.Lorem.sentences(3) |> Enum.join("\n")

    Reactor.run!(IoWriteReactor, %{path: path, content: content}, %{}, async?: false)

    assert content == File.read!(path)
  end
end
