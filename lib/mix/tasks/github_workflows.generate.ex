defmodule Mix.Tasks.GithubWorkflows.Generate do
  @moduledoc """
  Generates GitHub Actions YAML workflow files.

      $ mix github_workflows.generate [--dir .github/workflows] [--source .github/github_workflows.ex]

  Workflows will be read from the `source` file and stored in the `dir` directory.

  ## Options

    * `--dir` - directory path to store the generated workflows. Defaults to `.github/workflows`.
    * `--source` - path to the source file containing the map of workflows. Defaults to `.github/github_workflows.ex`.

  ## Example

  Given the following `.github/github_workflows.ex` file:

  ```elixir
  defmodule GithubWorkflows do
    def get do
      %{
        "main.yml" => main_workflow(),
        "pr.yml" => pr_workflow()
      }
    end

    defp main_workflow do
      [
        [
          name: "Main",
          on: [
            push: [
              branches: ["main"]
            ]
          ],
          jobs: [
            test: test_job(),
            deploy: [
              name: "Deploy",
              needs: :test,
              steps: [
                checkout_step(),
                [
                  name: "Deploy",
                  run: "make deploy"
                ]
              ]
            ]
          ]
        ]
      ]
    end

    defp pr_workflow do
      [
        [
          name: "PR",
          on: [
            pull_request: [
              branches: ["main"]
            ]
          ],
          jobs: [
            test: test_job()
          ]
        ]
      ]
    end

    defp test_job do
      [
        name: "Test",
        steps: [
          checkout_step(),
          [
            name: "Run tests",
            run: "make test"
          ]
        ]
      ]
    end

    defp checkout_step do
      [
        name: "Checkout",
        uses: "actions/checkout@v4"
      ]
    end
  end
  ```

  running the `mix github_workflows.generate` task will output the following files:

  `.github/workflows/main.yml`:

  ```yaml
  name: Main
  on:
    push:
      branches:
        - main
  jobs:
    test:
      name: Test
      steps:
        - name: Checkout
          uses: actions/checkout@v4
        - name: Run tests
          run: make test
    deploy:
      name: Deploy
      needs: test
      steps:
        - name: Checkout
          uses: actions/checkout@v4
        - name: Deploy
          run: make deploy
  ```

  `.github/workflows/pr.yml`:

  ```yaml
  name: PR
  on:
    pull_request:
      branches:
        - main
  jobs:
    test:
      name: Test
      steps:
        - name: Checkout
          uses: actions/checkout@v4
        - name: Run tests
          run: make test
  ```

  More complex workflows can be found here:
  https://github.com/optimumBA/github_workflows_generator/blob/main/.github/github_workflows.ex

  """

  use Mix.Task

  @default_dir_path ".github/workflows"
  @default_source_path ".github/github_workflows.ex"
  @switches [dir: :string, source: :string]

  @doc false
  @spec run(OptionParser.argv()) :: no_return()
  def run(argv) do
    {opts, _} = OptionParser.parse!(argv, strict: @switches)
    dir_path = Keyword.get(opts, :dir, @default_dir_path)
    source_path = Keyword.get(opts, :source, @default_source_path)

    with :ok <- check_file_exists(source_path),
         :ok <- maybe_create_dir(dir_path),
         :ok <- GithubWorkflowsGenerator.run(source_path, dir_path) do
      Mix.shell().info("Done! You can check the generated workflows in #{dir_path} directory.")
    else
      {:error, reason} ->
        Mix.raise(reason)
    end
  end

  defp check_file_exists(path) do
    if File.exists?(path) do
      :ok
    else
      {:error, "File not found: #{path}"}
    end
  end

  defp maybe_create_dir(path) do
    case File.mkdir_p(path) do
      :ok ->
        :ok

      {:error, reason} ->
        {:error, "Failed to create directory #{path}: #{reason}"}
    end
  end
end
