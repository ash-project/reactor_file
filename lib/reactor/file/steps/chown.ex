defmodule Reactor.File.Step.Chown do
  @arg_schema Spark.Options.new!(
                path: [
                  type: :string,
                  required: true,
                  doc: "The path of the file to change"
                ],
                uid: [
                  type: :pos_integer,
                  required: true,
                  doc: "The UID to change the file to"
                ]
              )

  @opt_schema Spark.Options.new!(
                revert_on_undo?: [
                  type: :boolean,
                  required: false,
                  default: false,
                  doc: "Change the UID back to the original value on undo?"
                ]
              )

  @moduledoc """
  A step which calls `File.chown/2`.

  ## Arguments

  #{Spark.Options.docs(@arg_schema)}

  ## Options

  #{Spark.Options.docs(@opt_schema)}

  ## Returns

  The original UID of the file before modification.
  """
  use Reactor.Step

  @doc false
  @impl true
  def run(arguments, _context, options) do
    with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
         {:ok, _options} <- Spark.Options.validate(options, @opt_schema),
         {:ok, %{uid: uid}} <- File.stat(arguments[:path]),
         :ok <- File.chown(arguments[:path], arguments[:uid]) do
      {:ok, uid}
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
  def undo(uid, arguments, _context, options) do
    if Keyword.get(options, :revert_on_undo?) do
      File.chown(arguments.path, uid)
    else
      :ok
    end
  end
end
