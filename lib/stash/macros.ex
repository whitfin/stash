defmodule Stash.Macros do
  @moduledoc false
  # A collection of Macros used to define internal function headers
  # and should not be used from outside this library (because they
  # make a lot of assumptions)

  defmacro deft(args, do: body) do
    { args, func_name, ctx, guards } = parse_args(args)

    cache = { :cache, ctx, nil }

    body = quote do
      cache = unquote(cache)
      if :ets.info(cache) == :undefined do
        :ets.new(cache, [
          { :read_concurrency, true },
          { :write_concurrency, true },
          :public,
          :set,
          :named_table
        ])
      end
      unquote(body)
    end

    remainder =
      args |> Enum.reverse |> Enum.reduce([], fn({ name, ctx, other }, state) ->
        case name do
          :cache -> state
          nvalue ->
            [{ "_" <> to_string(nvalue) |> String.to_atom, ctx, other } | state]
        end
      end)

    quote do
      def unquote(func_name)(unquote_splicing([cache|remainder])) when not is_atom(unquote(cache)) do
        raise ArgumentError, message: "Invalid ETS table name provided, got: #{inspect unquote(cache)}"
      end

      if unquote(guards != nil) do
        def unquote(func_name)(unquote_splicing(args)) when unquote(guards) do
          unquote(body)
        end
      else
        def unquote(func_name)(unquote_splicing(args)) do
          unquote(body)
        end
      end
    end
  end

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defp parse_args(args) do
    case args do
      { :when, _, [ { func_name, ctx, args }, guards ] } ->
        { args, func_name, ctx, guards }
      { func_name, ctx, args } ->
        { args, func_name, ctx, nil }
    end
  end

end
