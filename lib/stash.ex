defmodule Stash do
  use Stash.Macros

  @doc """
  Retrieves a value from the cache.

  ## Examples

      iex> Stash.set(:my_cache, "key", "value")
      iex> Stash.get(:my_cache, "key")
      "value"

      iex> Stash.get(:my_cache, "missing_key")
      nil

  """
  @spec get(atom, any) :: any
  deft get(cache, key) do
    case :ets.lookup(cache, key) do
      [{ ^key, value }] -> value
      _unrecognised_val -> nil
    end
  end

  @doc """
  Retrieves all keys from the cache, and returns them as an (unordered) list.

  ## Examples

      iex> Stash.set(:my_cache, "key1", "value1")
      iex> Stash.set(:my_cache, "key2", "value2")
      iex> Stash.set(:my_cache, "key3", "value3")
      iex> Stash.keys(:my_cache)
      [ "key2", "key1", "key3" ]

      iex> Stash.keys(:empty_cache)
      []

  """
  @spec keys(atom) :: [any]
  deft keys(cache) do
    :ets.foldr(fn({ key, _value }, keys) ->
      [key|keys]
    end, [], cache)
  end

  @doc """
  Sets a value in the cache against a given key.

  ## Examples

      iex> Stash.set(:my_cache, "key", "value")
      true

  """
  @spec set(atom, any, any) :: true
  deft set(cache, key, value) do
    :ets.insert(cache, { key, value })
  end

  @doc """
  Increments a key directly in the cache by `count`. If the key does not exist
  it is set to `initial` before **then** being incremented.

  ## Examples

      iex> Stash.set(:my_cache, "key", 1)
      iex> Stash.inc(:my_cache, "key")
      2

      iex> Stash.inc(:my_cache, "key", 2)
      4

      iex> Stash.inc(:my_cache, "missing_key", 1)
      1

      iex> Stash.inc(:my_cache, "a_missing_key", 1, 5)
      6

  """
  @spec inc(atom, any, number, number) :: number
  def inc(cache, key, count \\ 1, initial \\ 0)
  deft inc(cache, key, count, initial)
  when is_number(count) and is_number(initial) do
    :ets.update_counter(
      cache, key, { 2, count }, { key, initial }
    )
  end

  @doc """
  Removes a value from the cache.

  ## Examples

      iex> Stash.set(:my_cache, "key", "value")
      iex> Stash.get(:my_cache, "key")
      "value"

      iex> Stash.delete(:my_cache, "key")
      true

      iex> Stash.get(:my_cache, "key")
      nil

  """
  @spec delete(atom, any) :: true
  deft delete(cache, key), do: :ets.delete(cache, key)

  @doc """
  Removes a key from the cache, whilst also returning the last known value.

  ## Examples

      iex> Stash.set(:my_cache, "key", "value")
      iex> Stash.remove(:my_cache, "key")
      "value"

      iex> Stash.get(:my_cache, "key")
      nil

      iex> Stash.remove(:my_cache, "missing_key")
      nil

  """
  @spec remove(atom, any) :: any
  deft remove(cache, key) do
    case :ets.take(cache, key) do
      [{ ^key, value }] -> value
      _unrecognised_val -> nil
    end
  end

  @doc """
  Removes all items in the cache.

  ## Examples

      iex> Stash.set(:my_cache, "key1", "value1")
      iex> Stash.set(:my_cache, "key2", "value2")
      iex> Stash.set(:my_cache, "key3", "value3")
      iex> Stash.size(:my_cache)
      3

      iex> Stash.clear(:my_cache)
      true

      iex> Stash.size(:my_cache)
      0

  """
  @spec clear(atom) :: true
  deft clear(cache), do: :ets.delete_all_objects(cache)

  @doc """
  Returns information about the backing ETS table.

  ## Examples

      iex> Stash.info(:my_cache)
      [read_concurrency: true, write_concurrency: true, compressed: false,
       memory: 1361, owner: #PID<0.126.0>, heir: :none, name: :my_cache, size: 2,
       node: :nonode@nohost, named_table: true, type: :set, keypos: 1,
       protection: :public]

  """
  @spec info(atom) :: [ { atom, any } ]
  deft info(cache), do: :ets.info(cache)

  @doc """
  Checks whether the cache is empty.

  ## Examples

      iex> Stash.set(:my_cache, "key1", "value1")
      iex> Stash.set(:my_cache, "key2", "value2")
      iex> Stash.set(:my_cache, "key3", "value3")
      iex> Stash.empty?(:my_cache)
      false

      iex> Stash.clear(:my_cache)
      true

      iex> Stash.empty?(:my_cache)
      true

  """
  @spec empty?(atom) :: true | false
  deft empty?(cache), do: size(cache) == 0

  @doc """
  Determines whether a given key exists inside the cache.

  ## Examples

      iex> Stash.set(:my_cache, "key", "value")
      iex> Stash.exists?(:my_cache, "key")
      true

      iex> Stash.exists?(:my_cache, "missing_key")
      false

  """
  @spec exists?(atom, any) :: true | false
  deft exists?(cache, key), do: :ets.member(cache, key)

  @doc """
  Determines the size of the cache.

  ## Examples

      iex> Stash.set(:my_cache, "key1", "value1")
      iex> Stash.set(:my_cache, "key2", "value2")
      iex> Stash.set(:my_cache, "key3", "value3")
      iex> Stash.size(:my_cache)
      3

  """
  @spec size(atom) :: number
  deft size(cache), do: info(cache)[:size]

  @doc """
  Loads a cache into memory from DTS storage.

  ## Examples

      iex> Stash.load(:my_cache, "/tmp/temporary.dat")
      :ok

  """
  @spec load(atom, binary) :: atom
  deft load(cache, path) when is_binary(path) do
    case :dets.open_file(path, gen_dts_args(cache)) do
      { :ok, ^path } ->
        :dets.to_ets(path, cache)
        :dets.close(path)
      error_state -> error_state
    end
  end

  @doc """
  Persists a cache onto disk to allow reload after the process dies.

  ## Examples

      iex> Stash.persist(:my_cache, "/tmp/temporary.dat")
      :ok

  """
  @spec persist(atom, binary) :: atom
  deft persist(cache, path) when is_binary(path) do
    case :dets.open_file(path, gen_dts_args(cache)) do
      { :ok, ^path } ->
        :dets.from_ets(path, cache)
        :dets.close(path)
      error_state -> error_state
    end
  end

  # Generates the arguments for a DTS table based on a passed in ETS table
  defp gen_dts_args(cache) do
    info = info(cache)
    [ keypos: info[:keypos], type: info[:type] ]
  end

end
