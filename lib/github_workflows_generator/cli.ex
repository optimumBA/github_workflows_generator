defmodule GithubWorkflowsGenerator.CLI do
  @moduledoc false

  @default_dir_path ".github/workflows"
  @default_source_path ".github/github_workflows.ex"
  @switches [dir: :string, source: :string]

  @spec main(OptionParser.argv()) :: no_return()
  def main(argv) do
    {opts, _} = OptionParser.parse!(argv, strict: @switches)
    dir_path = Keyword.get(opts, :dir, @default_dir_path)
    source_path = Keyword.get(opts, :source, @default_source_path)

    case GithubWorkflowsGenerator.run(source_path, dir_path) do
      :ok ->
        IO.puts("Done! You can check the generated workflows in #{dir_path} directory.")

      {:error, reason} ->
        IO.puts(:stderr, "Error: #{reason}")
        exit({:shutdown, 1})
    end
  end
end
