# Stash
[![Build Status](https://img.shields.io/github/actions/workflow/status/whitfin/stash/ci.yml?branch=main)](https://github.com/whitfin/stash/actions) [![Coverage Status](https://img.shields.io/coveralls/whitfin/stash.svg)](https://coveralls.io/github/whitfin/stash) [![Hex.pm Version](https://img.shields.io/hexpm/v/stash.svg)](https://hex.pm/packages/stash) [![Documentation](https://img.shields.io/badge/docs-latest-blue.svg)](https://hexdocs.pm/stash/)

A very small wrapper around ETS, providing a more user-friendly key/value interface for new users.

Stash automatically creates a single ETS table with a set of defaults options to get running quickly.
This library is meant as a fast way to use ETS without needing anything flashy. If you need a more fully
featured caching solutions, please check out [cachex](https://github.com/whitfin/cachex) instead.

## Installation

This package can be installed via Hex, just add stash to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:stash, "~> 1.0"}]
end
```

## Getting Started

It's straightforward to get up and running quickly, just populate a namespace:

```elixir
iex(1)> Stash.set(:namespace, "my_key", "my_value")
true
iex(2)> Stash.get(:namespace, "my_key")
"my_value"
iex(3)> Stash.delete(:namespace, "my_key")
true
iex(4)> Stash.get(:namespace, "my_key")
nil
```

Stash uses a single table to store all namespaces, and is automatically bootstrapped during
application startup. Tables are created with currency enabled, and act as `:set`. In older
versions of Stash it was possible to bring your own table, but this has been removed in 2.x.

For further examples, as well as the rest of the API, please see the [documentation](http://hexdocs.pm/stash/Stash.html).

## Persistence

Useful for scripting and/or local tools, Stash includes (de)serialization to/from disk via `:dets`.

This is accessible via `Stash.persist/1` which will move your ETS tables into DTs, allowing you to
reload after your process has died. This is not synced in any way; call `Stash.persist/1` repeatedly
if this is required.

```elixir
iex(1)> Stash.set(:my_table, "key", "value")
true
iex(2)> Stash.size(:my_table)
1
iex(3)> Stash.persist("/tmp/my_persistence_file")
```

Reloading this data can be done via `Stash.load/1`, which accepts the same arguments:

```elixir
iex(6)> Stash.load("/tmp/my_persistence_file")
:ok
iex(7)> Stash.size(:my_table)
1
iex(1)> Stash.get(:my_table, "key")
"value"
```

Again, very simple but it does this job:

## Contributions

I expect the shape of this library will not change much due to the intended use case, but feel free
to suggest any improvements! You can test any changes as you'd expect:

```bash
$ mix test --trace
```

If you have any issues or feedback, please file an [issue](http://github.com/whitfin/stash/issues)!
