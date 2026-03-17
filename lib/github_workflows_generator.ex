defmodule GithubWorkflowsGenerator do
  @moduledoc false

  alias GithubWorkflowsGenerator.YmlEncoder

  @spec run(String.t(), String.t()) :: :ok | {:error, String.t()}
  def run(source_path, dir_path) do
    with :ok <- check_file_exists(source_path),
         :ok <- load_module(source_path),
         :ok <- create_dir(dir_path),
         {:ok, workflows} <- get_workflows(source_path) do
      for {filename, data} <- workflows do
        path = Path.join(dir_path, filename)

        yml =
          data
          |> List.first()
          |> YmlEncoder.encode()

        File.write!(path, yml)
      end

      :ok
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_dir(path) do
    case File.mkdir_p(path) do
      :ok -> :ok
      {:error, reason} -> {:error, "Failed to create directory #{path}: #{reason}"}
    end
  end

  defp check_file_exists(path) do
    if File.exists?(path) do
      :ok
    else
      {:error, "File not found: #{path}"}
    end
  end

  defp load_module(path) do
    cond do
      !match?([{GithubWorkflows, _}], Code.require_file(path)) ->
        {:error, "File #{path} does not contain a GithubWorkflows module."}

      !function_exported?(GithubWorkflows, :get, 0) ->
        {:error, "GithubWorkflows module does not contain a get/0 function."}

      true ->
        :ok
    end
  end

  defp get_workflows(source_path) do
    case apply(GithubWorkflows, :get, []) do
      %{} = workflows when map_size(workflows) > 0 ->
        {:ok, workflows}

      %{} ->
        {:error, "File #{source_path} does not contain any workflows."}

      _other ->
        {:error, "File #{source_path} does not have a valid structure."}
    end
  end
end
