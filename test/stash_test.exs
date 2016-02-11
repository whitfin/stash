defmodule StashTest do
  use ExUnit.Case

  @test_cache :my_test_cache
  @test_file "/tmp/stash_test_file"

  setup do
    Stash.clear(@test_cache)
    Enum.each(1..1000, fn(x) ->
      Stash.set(@test_cache, "key#{x}", "value#{x}")
    end)
    File.rm_rf!(@test_file)
    :ok
  end

  test "deft macro cannot accept non-atom caches" do
    assert_raise ArgumentError, "Invalid ETS table name provided, got: \"test\"", fn ->
      Stash.get("test", "key")
    end
  end

  test "test specific key retrieval" do
    Enum.each(1..1000, fn(x) ->
      assert(Stash.get(@test_cache, "key#{x}") == "value#{x}")
    end)
  end

  test "test key deletion" do
    Enum.each(1..1000, fn(x) ->
      assert(Stash.delete(@test_cache, "key#{x}"))
      assert(Stash.size(@test_cache) == 1000 - x)
    end)
  end

  test "test empty checking" do
    assert(!Stash.empty?(@test_cache))
    assert(Stash.clear(@test_cache))
    assert(Stash.empty?(@test_cache))
  end

  test "test key exists" do
    Enum.each(1..1000, fn(x) ->
      assert(Stash.exists?(@test_cache, "key#{x}"))
    end)
    assert(!Stash.exists?(@test_cache, "key1001"))
  end

  test "test key increment" do
    assert(Stash.set(@test_cache, "key", 1))
    assert(Stash.inc(@test_cache, "key") == 2)
    assert(Stash.inc(@test_cache, "key", 2) == 4)
    assert(Stash.inc(@test_cache, "keyX", 5, 5) == 10)
  end

  test "test key list retrieval" do
    keys = Stash.keys(@test_cache)
    assert(keys |> Enum.count == 1000)
  end

  test "test key removal" do
    Enum.each(1..1000, fn(x) ->
      assert(Stash.remove(@test_cache, "key#{x}") == "value#{x}")
      assert(Stash.size(@test_cache) == 1000 - x)
    end)
  end

  test "test key being set" do
    assert(Stash.set(@test_cache, "key", "value"))
    assert(Stash.get(@test_cache, "key") == "value")
  end

  test "test size retrieval" do
    assert(Stash.size(@test_cache) == 1000)
  end

  test "test clearing" do
    assert(Stash.size(@test_cache) == 1000)
    assert(Stash.clear(@test_cache))
    assert(Stash.size(@test_cache) == 0)
  end

  test "test persistance and loading" do
    assert(Stash.clear(@test_cache))
    assert(Stash.empty?(@test_cache))
    Enum.each(1..5, fn(x) ->
      Stash.set(@test_cache, "key#{x}", "value#{x}")
    end)
    assert(Stash.size(@test_cache) == 5)
    assert(Stash.persist(@test_cache, @test_file) == :ok)

    assert(Stash.clear(@test_cache))
    assert(Stash.empty?(@test_cache))
    assert(Stash.load(@test_cache, @test_file) == :ok)
    assert(Stash.size(@test_cache) == 5)
  end

end
