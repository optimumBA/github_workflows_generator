# mix github_workflows.generate

## Installation

To install from Hex, run:

```bash
mix archive.install hex github_workflows_generator
```

To build and install it locally, ensure any previous archive versions are removed:

```bash
mix archive.uninstall github_workflows.generate
```

Then run:

```bash
MIX_ENV=prod mix do archive.build, archive.install
```

## Usage

```bash
mix github_workflows.generate
```

To see available options, run:

```bash
mix help github_workflows.generate
```
