# Reactor.File

[![Build Status](https://drone.harton.dev/api/badges/james/reactor_file/status.svg)](https://drone.harton.dev/james/reactor_file)
[![Hex.pm](https://img.shields.io/hexpm/v/reactor_file.svg)](https://hex.pm/packages/reactor_file)
[![Hippocratic License HL3-FULL](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-FULL&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/full.html)

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

    file_read :read_file do
      path element(:reverse_files)
    end

    step :reverse_content do
      argument :content, result(:read_file)
      run &{:ok, &String.reverse(&1.content)}
    end

    file_write :write_file do
      path element(:reverse_files)
      contents result(:reverse_content)
    end

    return :write_file
  end

  return :reverese_files
end

Reactor.run!(ReverseFilesInDirectory, %{directory: "./to_reverse"})
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `reactor_file` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:reactor_file, "~> 0.4.1"}
  ]
end
```

Documentation for the latest release is available on [HexDocs](https://hexdocs.pm/reactor_file).

## Github Mirror

This repository is mirrored [on Github](https://github.com/jimsynz/reactor_file)
from it's primary location [on my Forgejo instance](https://harton.dev/james/reactor_file).
Feel free to raise issues and open PRs on Github.

## License

This software is licensed under the terms of the
[HL3-FULL](https://firstdonoharm.dev), see the `LICENSE.md` file included with
this package for the terms.

This license actively proscribes this software being used by and for some
industries, countries and activities. If your usage of this software doesn't
comply with the terms of this license, then [contact me](mailto:james@harton.nz)
with the details of your use-case to organise the purchase of a license - the
cost of which may include a donation to a suitable charity or NGO.
