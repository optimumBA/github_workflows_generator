defmodule GithubWorkflowsGenerator.CLITest do
  use ExUnit.Case, async: false

  alias GithubWorkflowsGenerator.CLI

  setup do
    on_exit(fn ->
      unload_workflows_module()
    end)
  end

  test "with defaults" do
    in_tmp(fn ->
      create_workflows_file(".github/github_workflows.ex")

      CLI.main([])

      assert_workflow("Main", ".github/workflows/main.yml")
      assert_workflow("PR", ".github/workflows/pr.yml")
    end)
  end

  test "with valid --dir" do
    in_tmp(fn ->
      create_workflows_file(".github/github_workflows.ex")

      CLI.main(["--dir", "custom_dir"])

      assert_workflow("Main", "custom_dir/main.yml")
      assert_workflow("PR", "custom_dir/pr.yml")
    end)
  end

  test "with valid --source" do
    in_tmp(fn ->
      source_path = ".github/workflows.ex"

      create_workflows_file(source_path)

      CLI.main(["--source", source_path])

      assert_workflow("Main", ".github/workflows/main.yml")
      assert_workflow("PR", ".github/workflows/pr.yml")
    end)
  end

  test "with invalid --source exits with code 1" do
    in_tmp(fn ->
      assert catch_exit(CLI.main(["--source", "invalid_source_path"])) == {:shutdown, 1}
    end)
  end

  defp in_tmp(function) do
    path = Path.join([System.tmp_dir!(), "github_workflows_generator", random_string()])

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)
      File.cd!(path, function)
    after
      File.rm_rf!(path)
    end
  end

  defp random_string do
    4
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
    |> binary_part(0, 6)
  end

  defp create_workflows_file(path) do
    path
    |> Path.dirname()
    |> File.mkdir_p!()

    File.write!(path, """
    defmodule GithubWorkflows do
      def get do
        %{
          "main.yml" => [[name: "Main"]],
          "pr.yml" => [[name: "PR"]]
        }
      end
    end
    """)
  end

  defp assert_workflow(name, path) do
    assert File.exists?(path)
    assert File.read!(path) == "name: #{name}\n"
  end

  defp unload_workflows_module do
    :code.purge(GithubWorkflows)
    :code.delete(GithubWorkflows)
  end
end
