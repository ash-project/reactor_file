# SPDX-FileCopyrightText: 2025 reactor_file contributors <https://github.com/ash-project/reactor_file/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule Reactor.File.Step.Touch do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the file to modify"
      ],
      time: [
        type:
          {:or,
           [
             {:struct, DateTime},
             {:tuple,
              [
                {:tuple, [:pos_integer, :pos_integer, :pos_integer]},
                {:tuple, [:pos_integer, :pos_integer, :pos_integer]}
              ]},
             :pos_integer,
             nil
           ]},
        required: false,
        doc: "The time to use as mtime and atime"
      ]
    ],
    opt_schema: [
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Recreate the directory if the Reactor is undoing changes"
      ]
    ],
    moduledoc: "A step which calls `File.touch/2`"

  defmodule Result do
    @moduledoc """
    The result of a `touch` step.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: nil | File.Stat.t(),
            after_stat: nil | File.Stat.t(),
            changed?: boolean
          }
  end

  defguardp is_year(y) when is_integer(y)
  defguardp is_month(m) when is_integer(m) and m >= 1 and m <= 12
  defguardp is_day(d) when is_integer(d) and d >= 1 and d <= 31

  defguardp is_date(date)
            when is_tuple(date) and tuple_size(date) == 3 and is_year(elem(date, 0)) and
                   is_month(elem(date, 1)) and is_day(elem(date, 2))

  defguardp is_hour(h) when is_integer(h) and h >= 0 and h <= 23
  defguardp is_minute(m) when is_integer(m) and m >= 0 and m <= 59
  defguardp is_second(m) when is_integer(m) and m >= 0 and m <= 59

  defguardp is_time(time)
            when is_tuple(time) and tuple_size(time) == 3 and is_hour(elem(time, 0)) and
                   is_minute(elem(time, 1)) and is_second(elem(time, 2))

  defguardp is_datetime(datetime)
            when is_tuple(datetime) and tuple_size(datetime) == 2 and is_date(elem(datetime, 0)) and
                   is_time(elem(datetime, 1))

  @doc false
  @impl true
  def mutate(arguments, context, _options) do
    time =
      case arguments.time do
        nil ->
          System.os_time(:second)

        %DateTime{} = datetime ->
          DateTime.to_unix(datetime, :second)

        datetime when is_datetime(datetime) ->
          datetime

        datetime when is_integer(datetime) ->
          datetime
      end

    with {:ok, before_stat} <- maybe_stat(arguments.path, [], context.current_step),
         :ok <- touch(arguments.path, time, context.current_step),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         before_stat: before_stat,
         after_stat: after_stat,
         changed?:
           case {before_stat, after_stat} do
             {nil, _} -> true
             {b, a} -> b != a
           end
       }}
    end
  end

  @doc false
  @impl true
  def revert(result, context, _options) do
    if is_nil(result.before_stat) do
      rm(result.path, context.current_stat)
    else
      write_stat(result.path, result.before_stat, [], context.current_stat)
    end
  end
end
