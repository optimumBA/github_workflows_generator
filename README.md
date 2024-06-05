# mix github_workflows.generate

[![hex.pm badge](https://img.shields.io/badge/hex.pm-5e3e80)](https://hex.pm/packages/github_workflows_generator)
[![hexdocs.pm badge](https://img.shields.io/badge/hexdocs.pm-5681bf)](https://hexdocs.pm/github_workflows_generator)

## Installation

Add `github_workflows_generator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:github_workflows_generator, "~> 0.1", only: :dev, runtime: false}
  ]
end
```

## Usage

```bash
mix github_workflows.generate
```

To see available options, run:

```bash
mix help github_workflows.generate
```
