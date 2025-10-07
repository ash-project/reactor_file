# SPDX-FileCopyrightText: 2025 James Harton, Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Types do
  @moduledoc false

  @doc false
  def file_modes do
    {:list,
     {:or,
      [
        {:in,
         [
           :append,
           :binary,
           :charlist,
           :compressed,
           :delayed_write,
           :exclusive,
           :raw,
           :read,
           :read_ahead,
           :sync,
           :write,
           :utf8
         ]},
        {:tuple, [{:literal, :read_ahead}, :pos_integer]},
        {:tuple, [{:literal, :delayed_write}, :pos_integer, :pos_integer]},
        {:tuple,
         [
           {:literal, :encoding},
           {:or,
            [
              {:in,
               [
                 :latin1,
                 :unicode,
                 :utf8,
                 :utf16,
                 :utf32
               ]},
              {:tuple, [{:literal, :utf16}, {:in, [:big, :little]}]},
              {:tuple, [{:literal, :utf32}, {:in, [:big, :little]}]}
            ]}
         ]}
      ]}}
  end
end
