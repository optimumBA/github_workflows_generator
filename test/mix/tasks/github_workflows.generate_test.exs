defmodule Mix.Tasks.GithubWorkflows.GenerateTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.GithubWorkflows.Generate

  setup do
    on_exit(fn ->
      unload_workflows_module()
    end)
  end

  test "with defaults" do
    in_tmp(fn ->
      create_workflows_file(".github/github_workflows.ex")

      Generate.run([])

      assert_workflow("Main", ".github/workflows/main.yml")
      assert_workflow("PR", ".github/workflows/pr.yml")
    end)
  end

  test "with valid --dir" do
    in_tmp(fn ->
      create_workflows_file(".github/github_workflows.ex")

      Generate.run(["--dir", "custom_dir"])

      assert_workflow("Main", "custom_dir/main.yml")
      assert_workflow("PR", "custom_dir/pr.yml")
    end)
  end

  test "with invalid --dir" do
    in_tmp(fn ->
      File.mkdir_p("github/workflows")
      File.chmod("github/workflows", 0o555)
      create_workflows_file(".github/github_workflows.ex")

      assert_raise Mix.Error, "Failed to create directory github/workflows/dir: eacces", fn ->
        Generate.run(["--dir", "github/workflows/dir"])
      end
    end)
  end

  test "with valid --source" do
    in_tmp(fn ->
      source_path = ".github/workflows.ex"

      create_workflows_file(source_path)

      Generate.run(["--source", source_path])

      assert_workflow("Main", ".github/workflows/main.yml")
      assert_workflow("PR", ".github/workflows/pr.yml")
    end)
  end

  test "with invalid --source" do
    in_tmp(fn ->
      assert_raise Mix.Error, "File not found: invalid_source_path", fn ->
        Generate.run(["--source", "invalid_source_path"])
      end

      File.write!("invalid_file.ex", "")

      assert_raise Mix.Error,
                   "File invalid_file.ex does not contain a GithubWorkflows module.",
                   fn ->
                     Generate.run(["--source", "invalid_file.ex"])
                   end

      File.write!("invalid_module.ex", """
      defmodule GithubWorkflows do
      end
      """)

      assert_raise Mix.Error, "GithubWorkflows module does not contain a get/0 function.", fn ->
        Generate.run(["--source", "invalid_module.ex"])
      end

      unload_workflows_module()

      File.write!("invalid_get.ex", """
      defmodule GithubWorkflows do
        def get do
        end
      end
      """)

      assert_raise Mix.Error, "File invalid_get.ex does not have a valid structure.", fn ->
        Generate.run(["--source", "invalid_get.ex"])
      end

      unload_workflows_module()

      File.write!("no_workflows.ex", """
      defmodule GithubWorkflows do
        def get do
          %{}
        end
      end
      """)

      assert_raise Mix.Error, "File no_workflows.ex does not contain any workflows.", fn ->
        Generate.run(["--source", "no_workflows.ex"])
      end
    end)
  end

  test "with invalid options" do
    assert_raise OptionParser.ParseError, fn ->
      Generate.run(["--invalid", "value"])
    end
  end

  defp in_tmp(function) do
    tmp_path = Path.expand("../../../tmp", __DIR__)
    path = Path.join([tmp_path, random_string()])

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
