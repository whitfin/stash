defmodule Stash do
  @moduledoc """
  This module provides a convenient interface around ETS/DTS without taking
  large performance hits. Designed for being thrown into a project for basic
  memory-based storage, perhaps with some form of persistence required.
  """

  @doc """
  Retrieves a value from the namespace.

  ## Examples

      iex> Stash.set(:my_namespace, "key", "value")
      iex> Stash.get(:my_namespace, "key")
      "value"

      iex> Stash.get(:my_namespace, "missing_key")
      nil

  """
  @spec get(atom(), any()) :: any()
  def get(namespace, key) do
    case :ets.lookup(:"$stash", {namespace, key}) do
      [{{^namespace, ^key}, value}] -> value
      _unrecognised_val -> nil
    end
  end

  @doc """
  Retrieves all keys from the namespace, and returns them as an (unordered) list.

  ## Examples

      iex> Stash.set(:my_namespace, "key1", "value1")
      iex> Stash.set(:my_namespace, "key2", "value2")
      iex> Stash.set(:my_namespace, "key3", "value3")
      iex> Stash.keys(:my_namespace)
      [ "key2", "key1", "key3" ]

      iex> Stash.keys(:empty_namespace)
      []

  """
  @spec keys(atom()) :: [any()]
  def keys(namespace) do
    :ets.foldr(
      fn
        {{^namespace, key}, _value}, keys ->
          [key | keys]

        _other, keys ->
          keys
      end,
      [],
      :"$stash"
    )
  end

  @doc """
  Sets a value in the namespace against a given key.

  ## Examples

      iex> Stash.set(:my_namespace, "key", "value")
      true

  """
  @spec set(atom(), any(), any()) :: true
  def set(namespace, key, value),
    do: :ets.insert(:"$stash", {{namespace, key}, value})

  @doc """
  Increments a key directly in the namespace by `count`. If the key does not exist
  it is set to `initial` before **then** being incremented.

  ## Examples

      iex> Stash.set(:my_namespace, "key", 1)
      iex> Stash.inc(:my_namespace, "key")
      2

      iex> Stash.inc(:my_namespace, "key", 2)
      4

      iex> Stash.inc(:my_namespace, "missing_key", 1)
      1

      iex> Stash.inc(:my_namespace, "a_missing_key", 1, 5)
      6

  """
  @spec inc(atom(), any(), number(), number()) :: number()
  def inc(namespace, key, count \\ 1, initial \\ 0) when is_number(count) and is_number(initial),
    do:
      :ets.update_counter(
        :"$stash",
        {namespace, key},
        {2, count},
        {key, initial}
      )

  @doc """
  Removes a value from the namespace.

  ## Examples

      iex> Stash.set(:my_namespace, "key", "value")
      iex> Stash.get(:my_namespace, "key")
      "value"

      iex> Stash.delete(:my_namespace, "key")
      true

      iex> Stash.get(:my_namespace, "key")
      nil

  """
  @spec delete(atom(), any()) :: true
  def delete(namespace, key) do
    :ets.delete(:"$stash", {namespace, key})
  end

  @doc """
  Removes a key from the namespace, whilst also returning the last known value.

  ## Examples

      iex> Stash.set(:my_namespace, "key", "value")
      iex> Stash.remove(:my_namespace, "key")
      "value"

      iex> Stash.get(:my_namespace, "key")
      nil

      iex> Stash.remove(:my_namespace, "missing_key")
      nil

  """
  @spec remove(atom(), any()) :: any()
  def remove(namespace, key) do
    case :ets.take(:"$stash", {namespace, key}) do
      [{{^namespace, ^key}, value}] -> value
      _unrecognised_val -> nil
    end
  end

  @doc """
  Removes all items in the namespace.

  ## Examples

      iex> Stash.set(:my_namespace, "key1", "value1")
      iex> Stash.set(:my_namespace, "key2", "value2")
      iex> Stash.set(:my_namespace, "key3", "value3")
      iex> Stash.size(:my_namespace)
      3

      iex> Stash.clear(:my_namespace)
      true

      iex> Stash.size(:my_namespace)
      0

  """
  @spec drop(atom) :: true
  def drop(namespace),
    do:
      :ets.select_delete(:"$stash", [
        {{{namespace, :_}, :_}, [], [true]}
      ])

  @spec clear() :: true
  def clear(),
    do: :ets.delete_all_objects(:"$stash")

  @doc """
  Checks whether the namespace is empty.

  ## Examples

      iex> Stash.set(:my_namespace, "key1", "value1")
      iex> Stash.set(:my_namespace, "key2", "value2")
      iex> Stash.set(:my_namespace, "key3", "value3")
      iex> Stash.empty?(:my_namespace)
      false

      iex> Stash.clear(:my_namespace)
      true

      iex> Stash.empty?(:my_namespace)
      true

  """
  @spec empty?(atom()) :: boolean()
  def empty?(namespace),
    do: size(namespace) == 0

  @doc """
  Determines whether a given key exists inside the namespace.

  ## Examples

      iex> Stash.set(:my_namespace, "key", "value")
      iex> Stash.exists?(:my_namespace, "key")
      true

      iex> Stash.exists?(:my_namespace, "missing_key")
      false

  """
  @spec exists?(atom, any) :: true | false
  def exists?(namespace, key) do
    case :ets.lookup(:"$stash", {namespace, key}) do
      [{{^namespace, ^key}, _value}] -> true
      _unrecognised_val -> false
    end
  end

  @doc """
  Determines the size of the namespace.

  ## Examples

      iex> Stash.set(:my_namespace, "key1", "value1")
      iex> Stash.set(:my_namespace, "key2", "value2")
      iex> Stash.set(:my_namespace, "key3", "value3")
      iex> Stash.size(:my_namespace)
      3

  """
  @spec size(atom) :: number
  def size(namespace),
    do:
      :ets.select_count(:"$stash", [
        {{{namespace, :_}, :_}, [], [true]}
      ])

  @doc """
  Returns information about the backing ETS table.

  ## Examples

      iex> Stash.info()
      [read_concurrency: true, write_concurrency: true, compressed: false,
       memory: 1361, owner: #PID<0.126.0>, heir: :none, name: :my_namespace, size: 2,
       node: :nonode@nohost, named_table: true, type: :set, keypos: 1,
       protection: :public]

  """
  @spec info() :: [{atom(), any()}]
  def info(),
    do: :ets.info(:"$stash")

  @doc """
  Loads a namespace into memory from DTS storage.

  ## Examples

      iex> Stash.load("/tmp/temporary.dat")
      :ok

  """
  @spec load(binary()) :: atom()
  def load(path) when is_binary(path) do
    args = gen_dts_args()
    path = :binary.bin_to_list(path)

    with {:ok, ^path} <- :dets.open_file(path, args) do
      :dets.to_ets(path, :"$stash")
      :dets.close(path)
    end
  end

  @doc """
  Persists a namespace onto disk to allow reload after the process dies.

  ## Examples

      iex> Stash.persist(:my_namespace, "/tmp/temporary.dat")
      :ok

  """
  @spec persist(binary()) :: atom()
  def persist(path) when is_binary(path) do
    args = gen_dts_args()
    path = :binary.bin_to_list(path)

    with {:ok, ^path} <- :dets.open_file(path, args) do
      :dets.from_ets(path, :"$stash")
      :dets.close(path)
    end
  end

  # Generates the arguments for a DTS table based on a passed in ETS table
  defp gen_dts_args() do
    info = info()
    [keypos: info[:keypos], type: info[:type]]
  end
end
