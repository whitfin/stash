defmodule Stash.App do
  @moduledoc false
  # Application callback to start any global services.
  use Application

  @doc """
  Starts the global table for Stash.
  """
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children =
      [
        %{
          id: Eternal,
          start:
            {Eternal, :start_link,
             [
               :"$stash",
               [
                 {:read_concurrency, true},
                 {:write_concurrency, true}
               ],
               [quiet: true]
             ]},
          type: :supervisor
        }
      ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
