defmodule Reactor.File.Step.MkdirP do
  @moduledoc false
  use Reactor.File.Step,
    arg_schema: [
      path: [
        type: :string,
        required: true,
        doc: "The path of the directory to create"
      ]
    ],
    opt_schema: [
      revert_on_undo?: [
        type: :boolean,
        required: false,
        default: false,
        doc: "Remove the created directory(s) if the Reactor is undoing changes"
      ]
    ]

  defmodule Result do
    @moduledoc """
    The result of a `mkdir_p` step.

    Contains the path being changed, and the stats before and after the change.
    """
    defstruct path: nil, created: [], before_stat: nil, after_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            created: [Path.t()],
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def mutate(arguments, context, _options) do
    with {:ok, before_stat} <- maybe_stat(arguments.path, [], context.current_step),
         {:ok, also_made} <- missing_parent_dirs(arguments.path),
         :ok <- mkdir_p(arguments.path, context.current_step),
         {:ok, after_stat} <- stat(arguments.path, [], context.current_step) do
      {:ok,
       %Result{
         path: arguments.path,
         created: also_made,
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: is_nil(before_stat)
       }}
    end
  end

  @doc false
  def revert(result, context, _options) do
    Enum.reduce_while(result.created, :ok, fn dir, :ok ->
      case rmdir(dir, context.current_step) do
        :ok -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp missing_parent_dirs(path) do
    segments = Path.split(path)

    1..length(segments)
    |> Enum.map(fn how_many ->
      segments
      |> Enum.take(how_many)
      |> Path.join()
    end)
    |> Enum.reverse()
    |> missing_parent_dirs([])
  end

  defp missing_parent_dirs([], dirs), do: {:ok, Enum.reverse(dirs)}

  defp missing_parent_dirs([head | tail], dirs) do
    if File.dir?(head) do
      {:ok, Enum.reverse(dirs)}
    else
      missing_parent_dirs(tail, [head | dirs])
    end
  end
end
