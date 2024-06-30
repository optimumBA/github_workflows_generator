defmodule GithubWorkflowsGenerator.MixProject do
  use Mix.Project

  @repo "https://github.com/optimumBA/github_workflows_generator"
  @version "0.1.3"

  def project do
    [
      app: :github_workflows_generator,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: optimum_deps() ++ app_deps(),

      # Hex package
      description: "Generate GitHub Actions workflows",
      package: package(),

      # CI
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      preferred_cli_env: [
        ci: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        credo: :test,
        dialyzer: :test
      ],
      test_coverage: [tool: ExCoveralls],

      # Docs
      name: "GithubWorkflowsGenerator",
      source_url: @repo,
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @repo},
      maintainers: ["Almir Sarajčić"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp optimum_deps do
    [
      {:credo, "~> 1.7", only: :test, runtime: false},
      {:dialyxir, "~> 1.4", only: :test, runtime: false},
      {:doctest_formatter, "~> 0.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:mix_audit, "~> 2.1", only: :test, runtime: false}
    ]
  end

  defp app_deps do
    []
  end

  defp aliases do
    [
      setup: [
        "deps.get",
        "cmd npm i -D prettier prettier-plugin-toml"
      ],
      ci: [
        "deps.unlock --check-unused",
        "deps.audit",
        "hex.audit",
        "format --check-formatted",
        "cmd npx prettier -c .",
        "credo --strict",
        "dialyzer",
        "test --cover --warnings-as-errors"
      ],
      prettier: ["cmd npx prettier -w ."]
    ]
  end
end
