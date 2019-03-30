defmodule Stash.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/stash"
  @url_github "https://github.com/zackehh/stash"

  def project do
    [
      app: :stash,
      name: "Stash",
      description: "Simple ETS backed key/value store for Elixir",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "LICENSE",
          "README.md"
        ],
        licenses: [ "MIT" ],
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        },
        maintainers: [ "Isaac Whitfield" ]
      },
      version: "1.0.0",
      elixir: "~> 1.7",
      deps: deps(),
      docs: [
        extras: [ "README.md" ],
        source_ref: "master",
        source_url: @url_github
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      # documentation
      { :earmark, "~> 0.2.1",  optional: true, only: :docs },
      { :ex_doc,  "~> 0.11.3", optional: true, only: :docs },
      # testing
      { :benchfella,  "~> 0.3.1", optional: true, only: :test },
      { :benchwarmer, "~> 0.0.2", optional: true, only: :test },
      { :exprof,      "~> 0.2.0", optional: true, only: :test }
    ]
  end
end
