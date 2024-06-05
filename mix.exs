defmodule GithubWorkflowsGenerator.MixProject do
  use Mix.Project

  @repo "https://github.com/optimumBA/github_workflows_generator"
  @version "0.1.1"

  def project do
    [
      app: :github_workflows_generator,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),

      # Code checks
      preferred_cli_env: [
        ci: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        credo: :test,
        dialyzer: :test
      ],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],

      # Docs
      name: "GithubWorkflowsGenerator",
      source_url: @repo,
      docs: docs(),

      # Hex package
      description: "Generate GitHub Actions workflows",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "Mix.Tasks.GithubWorkflows.Generate",
      source_ref: "v#{@version}"
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
  defp deps do
    [
      {:credo, "~> 1.7", only: [:test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:test], runtime: false},
      {:fast_yaml, "~> 1.0"},
      {:ex_doc, "~> 0.34", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.18", only: [:test], runtime: false},
      {:mix_audit, "~> 1.0", only: [:test], runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "deps.unlock --check-unused",
        "deps.audit",
        "hex.audit",
        "format --check-formatted",
        "cmd npx prettier -c .",
        "credo --strict",
        "dialyzer",
        "coveralls"
      ],
      prettier: ["cmd npx prettier -w ."]
    ]
  end
end
