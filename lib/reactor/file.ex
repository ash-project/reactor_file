# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File do
  @moduledoc """
  An extension which provides steps for working with the local filesystem within
  Reactor.
  """

  use Spark.Dsl.Extension,
    dsl_patches:
      Enum.map(
        [
          Reactor.File.Dsl.Chgrp,
          Reactor.File.Dsl.Chown,
          Reactor.File.Dsl.Chmod,
          Reactor.File.Dsl.CloseFile,
          Reactor.File.Dsl.Cp,
          Reactor.File.Dsl.CpR,
          Reactor.File.Dsl.Glob,
          Reactor.File.Dsl.IoBinRead,
          Reactor.File.Dsl.IoBinStream,
          Reactor.File.Dsl.IoRead,
          Reactor.File.Dsl.IoStream,
          Reactor.File.Dsl.IoWrite,
          Reactor.File.Dsl.Ln,
          Reactor.File.Dsl.LnS,
          Reactor.File.Dsl.Lstat,
          Reactor.File.Dsl.Mkdir,
          Reactor.File.Dsl.MkdirP,
          Reactor.File.Dsl.OpenFile,
          Reactor.File.Dsl.ReadFile,
          Reactor.File.Dsl.ReadLink,
          Reactor.File.Dsl.Rm,
          Reactor.File.Dsl.Rmdir,
          Reactor.File.Dsl.Stat,
          Reactor.File.Dsl.Touch,
          Reactor.File.Dsl.WriteFile,
          Reactor.File.Dsl.WriteStat
        ],
        &%Spark.Dsl.Patch.AddEntity{
          section_path: [:reactor],
          entity: &1.__entity__()
        }
      ),
    transformers: [Reactor.File.Transformer]
end
