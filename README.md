# mix github_workflows.generate

[![hex.pm badge](https://img.shields.io/badge/hex.pm-5e3e80)](https://hex.pm/packages/github_workflows_generator)
[![hexdocs.pm badge](https://img.shields.io/badge/hexdocs.pm-5681bf)](https://hexdocs.pm/github_workflows_generator)

## Usage as a Mix task

Add `github_workflows_generator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:github_workflows_generator, "~> 0.1", only: :dev, runtime: false}
  ]
end
```

Then run:

```bash
mix github_workflows.generate
```

To see available options, run:

```bash
mix help github_workflows.generate
```

## Usage as an escript

For projects without `mix.exs`, install the escript globally:

```bash
mix escript.install hex github_workflows_generator
```

Then run from any directory:

```bash
github_workflows_generator
```
