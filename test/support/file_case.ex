# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule FileCase do
  @moduledoc """
  An ExUnit case template which creates a temporary directory for every test run.
  """

  use ExUnit.CaseTemplate

  setup(context) do
    test_sig =
      context
      |> Map.take(~w[line module file test]a)
      |> :erlang.phash2()
      |> Integer.to_string(16)

    base = System.tmp_dir!()

    tmp_dir = Path.join(base, test_sig)
    File.mkdir_p!(tmp_dir)

    on_exit(fn ->
      File.rm_rf!(tmp_dir)
    end)

    {:ok, tmp_dir: tmp_dir}
  end

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  @lorem_file_opts Spark.Options.new!(
                     name: [
                       type: {:or, [:string, {:fun, [], :string}]},
                       required: false
                     ],
                     paragraphs: [type: :pos_integer, required: false],
                     prefix: [
                       type: {:or, [nil, :string]},
                       required: false,
                       default: nil
                     ],
                     suffix: [
                       type: {:or, [nil, :string]},
                       required: false,
                       default: nil
                     ]
                   )

  @doc "Create a file at the specified path with lorem contents"
  def lorem_file(tmp_dir, opts \\ []) do
    opts = Spark.Options.validate!(opts, @lorem_file_opts)

    name =
      case opts[:name] do
        name when is_binary(name) -> name
        fun when is_function(fun, 0) -> fun.()
        nil -> Faker.Lorem.word()
      end

    paragraphs =
      case opts[:paragraphs] do
        num when is_integer(num) and num > 0 -> num
        nil -> :rand.uniform(3) + 3
      end

    path = Path.join(tmp_dir, "#{opts[:prefix]}#{name}#{opts[:suffix]}")

    content =
      paragraphs
      |> Faker.Lorem.paragraphs()
      |> Enum.join("\n\n")

    File.write!(path, content)

    path
  end

  @lorem_files_opts Spark.Options.new!(
                      how_many: [
                        type: :pos_integer,
                        required: false
                      ],
                      lorem_file_opts: [
                        type: {:keyword_list, @lorem_file_opts.schema},
                        required: false,
                        default: []
                      ]
                    )

  @doc "Create a number of files at the specified path with lorem contents"
  def lorem_files(tmp_dir, opts \\ []) do
    opts = Spark.Options.validate!(opts, @lorem_files_opts)

    how_many = opts[:how_many] || :rand.uniform(3) + 3
    lorem_file_opts = opts[:lorem_file_opts] || []

    1..how_many
    |> Enum.map(fn i ->
      lorem_file_opts =
        lorem_file_opts
        |> Keyword.put_new_lazy(:name, fn ->
          "#{i}_#{Faker.Lorem.word()}"
        end)

      lorem_file(tmp_dir, lorem_file_opts)
    end)
    |> Enum.sort()
  end
end
