# Stash
[![Build Status](https://travis-ci.org/zackehh/stash.svg?branch=master)](https://travis-ci.org/zackehh/stash)

A very small wrapping implementation around ETS, providing a more user-friendly key/value interface for new users. Takes care of setting up a new ETS table as needed with a default set of options to avoid having to deal with configurations. This library is meant as a fast way to use ETS without anything flashy, so don't expect many features over what's already here (which isn't much, intentionally).

## Installation

This package can be installed via Hex, just add stash to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:stash, "~> 1.0.0"}]
end
```

## Quick Usage

It's straightforward to get going:

```elixir
iex(1)> Stash.set(:my_cache, "my_key", "my_value")
true
iex(2)> Stash.get(:my_cache, "my_key")
"my_value"
iex(3)> Stash.delete(:my_cache, "my_key")
true
iex(4)> Stash.get(:my_cache, "my_key")
nil
```

For further examples, as well as the rest of the API, please see the [documentation](http://hexdocs.pm/stash/Stash.html).

## A Note On Table Configuration

By default, Stash will create a table with the following configuration:

```elixir
[
  { :read_concurrency, true },
  { :write_concurrency, true },
  :public,
  :set,
  :named_table
]
```

If you **don't** wish to have this configuration, please create your ETS table in advance of using Stash to access it. However keep in mind that Stash is written with the assumption that you're using either a `set` or `ordered_set`, so it's best to stick to those. The defaults should be ok in most cases, so unless you're already thinking that you want a setting changed above, you're probably fine.

## Persistence

A neat little feature is the ability to persist a cache to disk, by calling `Stash.persist/2`. This will move your ETS tables into DTS, allowing you to reload after your process has died. This is not kept in sync due to the overhead involved, so it might be an idea to schedule persistance if you rely on it. To reload, call `Stash.load/2`.

```elixir
iex(1)> Stash.set(:my_cache, "key", "value")
true
iex(2)> Stash.size(:my_cache)
1
iex(3)> Stash.persist(:my_cache, "/tmp/my_persistence_file")
:ok
iex(4)> Stash.delete(:my_cache, "key")
true
iex(5)> Stash.size(:my_cache)
0
iex(6)> Stash.load(:my_cache, "/tmp/my_persistence_file")
:ok
iex(7)> Stash.size(:my_cache)
1
iex(1)> Stash.get(:my_cache, "key")
"value"
```

## Issues/Contributions

If you spot any issues with the implementation, please file an [issue](http://github.com/zackehh/stash/issues) or even a PR. Like I mentioned above, not too many features will make it into this lib as it's a small wrapping library, nothing special.

Make sure to test your changes though!

```bash
$ mix test --trace
```
