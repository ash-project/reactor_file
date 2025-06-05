<img src="https://github.com/ash-project/reactor/blob/main/logos/reactor-logo-light-small.png?raw=true#gh-light-mode-only" alt="Logo Light" width="250">
<img src="https://github.com/ash-project/reactor/blob/main/logos/reactor-logo-dark-small.png?raw=true#gh-dark-mode-only" alt="Logo Dark" width="250">

# Reactor.File

[![Build Status](https://github.com/ash-project/reactor_file/actions/workflows/elixir.yml/badge.svg)](https://github.com/ash-project/reactor/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex version badge](https://img.shields.io/hexpm/v/reactor_file.svg)](https://hex.pm/packages/reactor_file)

A [Reactor](https://github.com/ash-project/reactor) extension that provides steps for working with the local filesytem.

## Example

The following example uses Reactor to reverse all the files in the specified directory.

```elixir
defmodule ReverseFilesInDirectory do
  use Reactor, extensions: [Reactor.File]

  input :directory

  glob :all_files do
    pattern input(:directory), transform: &Path.join(&1, "*")
  end

  map :reverse_files do
    source result(:all_files)

    read_file :read_file do
      path element(:reverse_files)
    end

    step :reverse_content do
      argument :content, result(:read_file)
      run &{:ok, &String.reverse(&1.content)}
    end

    write_file :write_file do
      path element(:reverse_files)
      contents result(:reverse_content)
    end

    return :write_file
  end

  return :reverse_files
end

Reactor.run!(ReverseFilesInDirectory, %{directory: "./to_reverse"})
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `reactor_file` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:reactor_file, "~> 0.18.1"}
  ]
end
```

Documentation for the latest release is available on [HexDocs](https://hexdocs.pm/reactor_file).

## Licence

`reactor` is licensed under the terms of the [MIT
license](https://opensource.org/licenses/MIT). See the [`LICENSE` file in this
repository](https://github.com/ash-project/reactor_file/blob/main/LICENSE)
for details.
