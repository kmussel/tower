defmodule Tower.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tower,
      version: "0.3.1",
      elixir: "~> 1.5",
      package: package(),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [
        :logger,
        :cowboy,
        :postgrex,
        :ecto,
        :plug,
        :comeonin,
        :secure_random
      ],
      mod: {Tower, []},
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:postgrex, "0.13.3"},
      {:ecto, "2.2.1"},
      {:cowboy, "1.1.2"},
      {:plug,   "1.4.3"},
      {:poison, "3.1.0"},
      {:comeonin, "3.2.0"},
      {:secure_random, "0.5.1"}
    ]
  end

  defp package do
    [
      maintainers:  ["Kevin Musselman"],
      licenses:     ["MIT"],
      links:        %{"Github" => "https://github.com/metismachine/tower"},
      files:        ["lib", "mix.exs", "README.md"],
    ]
  end
end
