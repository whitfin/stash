defmodule StashTest do
  use ExUnit.Case

  test "simple getting and putting of keys" do
    key = "one"
    value = 1

    assert Stash.get(:simple_get_put, key) == nil
    assert Stash.set(:simple_get_put, key, value)
    assert Stash.get(:simple_get_put, key) == 1

    assert Stash.get(:simple_get_get, key) == nil
  end

  test "simple removal of keys" do
    key = "one"
    value = 1

    assert Stash.get(:simple_removal, key) == nil
    assert Stash.set(:simple_removal, key, value)
    assert Stash.get(:simple_removal, key) == 1

    assert Stash.delete(:simple_removal, key)
    assert Stash.get(:simple_removal, key) == nil

    assert Stash.set(:simple_removal, key, value)
    assert Stash.get(:simple_removal, key) == 1

    assert Stash.remove(:simple_removal, key) == value
    assert Stash.get(:simple_removal, key) == nil
  end

  test "simple key existence" do
    key = "one"
    value = 1

    refute Stash.exists?(:simple_exists, key)
    assert Stash.set(:simple_exists, key, value)
    assert Stash.exists?(:simple_exists, key)
  end

  test "simple key increments" do
    key = "one"
    key2 = "two"

    assert Stash.set(:simple_increment, key, 1)

    assert Stash.inc(:simple_increment, key) == 2
    assert Stash.inc(:simple_increment, key, 2) == 4

    assert Stash.inc(:simple_increment, key2, 5, 5) == 10
  end

  test "checking namespace sizes" do
    key = "one"
    value = 1

    assert Stash.empty?(:simple_sizing)
    assert Stash.size(:simple_sizing) == 0

    assert Stash.set(:simple_sizing, key, value)
    assert Stash.get(:simple_sizing, key) == 1

    refute Stash.empty?(:simple_sizing)
    assert Stash.size(:simple_sizing) == 1

    assert Stash.empty?(:sizing_simple)
    assert Stash.size(:sizing_simple) == 0
  end

  test "checking namespace keys" do
    assert Stash.set(:simple_keys, 1, 1)
    assert Stash.set(:simple_keys, 2, 2)
    assert Stash.set(:simple_keys, 3, 3)

    assert Enum.sort(Stash.keys(:simple_keys)) == [1, 2, 3]
  end

  test "test persistance and loading" do
    assert Stash.clear()
    assert Stash.empty?(:simple_persistence)

    Enum.each(1..5, fn x ->
      assert Stash.set(:simple_persistence, "key#{x}", "value#{x}")
    end)

    assert Stash.size(:simple_persistence) == 5
    assert Stash.persist("/tmp/stash_test_file") == :ok

    assert Stash.clear()
    assert Stash.empty?(:simple_persistence)

    assert Stash.load("/tmp/stash_test_file") == :ok
    assert Stash.size(:simple_persistence) == 5
  end
end
