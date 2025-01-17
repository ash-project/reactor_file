defmodule Reactor.File.Step.Chmod do
  @arg_schema Spark.Options.new!(
                mode: [
                  type: :pos_integer,
                  required: true,
                  doc: "The mode to set the file to"
                ],
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the file to change"
                ]
              )

  @opt_schema Spark.Options.new!(
                revert_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Change the file mode back to the original value on undo?"
                ]
              )

  @moduledoc """
  A step which calls `File.chmod/2`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}

  ## Returns

  The original GID of the file before modification.
  """
  use Reactor.Step
  import Reactor.File.Ops

  defmodule Result do
    @moduledoc """
    The result of a `chmod` step.

    Contains the path that was changed, as well as before and after stats.
    """
    defstruct path: nil, before_stat: nil, after_stat: nil, changed?: nil

    @type t :: %__MODULE__{
            path: Path.t(),
            before_stat: File.Stat.t(),
            after_stat: File.Stat.t(),
            changed?: boolean
          }
  end

  @doc false
  @impl true
  def run(arguments, context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, _options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, before_stat} <- stat(arguments[:path], [], context.current_step),
         :ok <- chmod(arguments[:path], arguments[:mode], context.current_step),
         {:ok, after_stat} <- stat(arguments[:path], [], context.current_step) do
      {:ok,
       %Result{
         path: arguments[:path],
         before_stat: before_stat,
         after_stat: after_stat,
         changed?: before_stat.mode != after_stat.mode
       }}
    end
  end

  @doc false
  @impl true
  def can?(%{impl: {_, options}}, :undo) do
    with {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
      options[:revert_on_undo?]
    end
  end

  def can?(_, :undo), do: false
  def can?(step, capability), do: super(step, capability)

  @doc false
  @impl true
  def undo(result, _, _, _) when result.changed? == false, do: :ok

  def undo(result, _arguments, context, options) do
    if Keyword.get(options, :revert_on_undo?) do
      chmod(result.path, result.before_stat.mode, context.current_step)
    else
      :ok
    end
  end
end
