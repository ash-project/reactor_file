defmodule Reactor.File.Step do
  @moduledoc false

  @callback mutate(arguments :: map, context :: map, options :: keyword) ::
              {:ok, any} | {:error, any}

  @callback revert(result :: struct, context :: map, options :: keyword) ::
              :ok | {:error, any}

  defmacro __using__(opts) do
    quote do
      use Reactor.Step
      import unquote(__MODULE__)
      import Reactor.File.Ops
      @behaviour unquote(__MODULE__)

      @arg_schema Spark.Options.new!(unquote(opts[:arg_schema]))
      @opt_schema Spark.Options.new!(unquote(opts[:opt_schema]))

      @moduledoc """
      #{unquote(opts[:moduledoc])}

      ## Arguments

      #{Spark.Options.docs(@arg_schema)}

      ## Options

      #{Spark.Options.docs(@opt_schema)}
      """

      @doc false
      @impl true
      def run(arguments, context, options) do
        with {:ok, arguments} <- Spark.Options.validate(Enum.to_list(arguments), @arg_schema),
             {:ok, options} <- Spark.Options.validate(options, @opt_schema) do
          arguments
          |> Map.new()
          |> mutate(context, options)
        end
      end

      @doc false
      @impl true
      def can?(%{impl: {_, options}}, :undo), do: Keyword.get(options, :revert_on_undo?, false)
      def can?(_, :undo), do: false
      def can?(step, capability), do: super(step, capability)

      @doc false
      @impl true
      def undo(result, _, _, _) when result.changed? == false, do: :ok

      def undo(result, _arguments, context, options) do
        if Keyword.get(options, :revert_on_undo?) do
          revert(result, context, options)
        else
          :ok
        end
      end

      @doc false
      @impl true
      def revert(_result, _context, _options) do
        raise RuntimeError, message: "Not implemented"
      end

      defoverridable revert: 3
    end
  end
end
