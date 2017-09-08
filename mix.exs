defmodule Tower.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tower,
      version: "0.1.0",
      elixir: "~> 1.5",
      package: package(),
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
        :plug,
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug,   "~> 1.3"},
      {:poison, "~> 3.1"}
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
