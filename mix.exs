# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.MixProject do
  @moduledoc """
  A Reactor extension which provides steps for working with the filesystem.
  """

  @version "0.18.3"
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :reactor_file,
      consolidate_protocols: Mix.env() != :dev,
      deps: deps(),
      description: @moduledoc,
      docs: docs(),
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      source_url: "https://github.com/ash-project/reactor_file",
      homepage_url: "https://github.com/ash-project/reactor_file",
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: :reactor_file,
      files:
        ~w[lib .formatter.exs mix.exs README* LICENSE* CHANGELOG* documentation usage-rules.md],
      licenses: ["MIT"],
      links: %{
        "Source" => "https://github.com/ash-project/reactor_file",
        "Changelog" => "https://github.com/ash-project/reactor_file/blob/main/CHANGELOG.md",
        "Sponsor" => "https://github.com/sponsors/jimsynz",
        "REUSE Compliance" =>
          "https://api.reuse.software/info/github.com/ash-project/reactor_file"
      },
      maintainers: [
        "James Harton <james@harton.nz>"
      ],
      source_url: "https://github.com/ash-project/reactor_file"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.0", only: ~w[dev test]a, runtime: false},
      {:dialyxir, "~> 1.0", only: ~w[dev test]a, runtime: false},
      {:doctor, "~> 0.22", only: ~w[dev test]a, runtime: false},
      {:ex_check, "~> 0.16", only: ~w[dev test]a, runtime: false},
      {:ex_doc, "~> 0.38", only: ~w[dev test]a, runtime: false},
      {:faker, "~> 0.18.0", only: ~w[dev test]a, runtime: false},
      {:git_ops, "~> 2.6", only: ~w[dev test]a, runtime: false},
      {:igniter, "~> 0.6", only: ~w[dev test]a},
      {:mix_audit, "~> 2.0", only: ~w[dev test]a, runtime: false},
      {:reactor, "~> 0.15"},
      {:spark, "~> 2.0"}
    ]
  end

  defp aliases do
    [
      credo: "credo --strict",
      docs: [
        "spark.cheat_sheets",
        "docs",
        "spark.replace_doc_links"
      ],
      "spark.formatter": "spark.formatter --extensions Reactor.File",
      "spark.cheat_sheets": "spark.cheat_sheets --extensions Reactor.File",
      "spark.cheat_sheets_in_search": "spark.cheat_sheets_in_search --extensions Reactor.File"
    ]
  end

  defp docs do
    [
      extras: extra_documentation(),
      extras_section: "GUIDES",
      formatters: ["html"],
      filter_modules: ~r/^Elixir\.Reactor/,
      groups_for_extras: extra_documentation_groups(),
      main: "readme",
      source_url_pattern:
        "https://github.com/ash-project/reactor_file/src/branch/main/%{path}#L%{line}",
      spark: [
        extension: [
          %{
            module: Reactor.File,
            name: "Reactor.File",
            target: "Reactor",
            type: "Reactor"
          }
        ]
      ]
    ]
  end

  defp extra_documentation do
    ["README.md"]
    |> Enum.concat(Path.wildcard("documentation/**/*.{md,livemd,cheatmd}"))
    |> Enum.map(&{String.to_atom(&1), []})
  end

  defp extra_documentation_groups do
    [
      DSLs: ~r'documentation/dsls'
    ]
  end

  defp elixirc_paths(env) when env in ~w[dev test]a, do: ~w[lib test/support]
  defp elixirc_paths(_), do: ~w[lib]
end
