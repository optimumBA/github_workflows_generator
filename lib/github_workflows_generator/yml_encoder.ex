defmodule GithubWorkflowsGenerator.YmlEncoder do
  @moduledoc false

  @spec encode(term()) :: String.t()
  def encode(data) do
    data
    |> Enum.at(0)
    |> :fast_yaml.encode()
    |> to_string()
    # Trim trailing space
    |> String.replace("\s\n", "\n")
    # Avoid putting list element in new line after -
    |> String.replace(~r/-\n\s+/, "-\s")
    # Trim trailing newline inside strings
    |> String.replace(~S(\n"), ~S("))
    # Unquote strings
    |> String.replace(~r<"([a-z0-9@_\-\.,: \{\}\$/\*\(\)'!=&\<\>~]+)">i, "\\1")
    # Add newline to the EOF
    |> Kernel.<>("\n")
  end
end
