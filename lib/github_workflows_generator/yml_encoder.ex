defmodule GithubWorkflowsGenerator.YmlEncoder do
  @moduledoc false

  @spec encode(term()) :: String.t()
  def encode(data) do
    data
    |> to_yml()
    |> String.trim()
    |> Kernel.<>("\n")
  end

  defp to_yml(data, level \\ 0, indent? \\ false)

  defp to_yml(data, level, indent?) when is_list(data) do
    if Keyword.keyword?(data) do
      handle_keyword_list(data, level, indent?)
    else
      Enum.map_join(
        data,
        "\n",
        &(String.duplicate("  ", level) <> "- " <> to_yml(&1, level + 1, false))
      )
    end
  end

  defp to_yml(data, level, _indent?) do
    cond do
      !is_binary(data) ->
        value(data)

      String.contains?(data, "\n") ->
        values =
          data
          |> String.split("\n", trim: true)
          |> Enum.map_join("\n", &(String.duplicate("  ", level) <> value(&1)))

        "|\n#{values}"

      true ->
        value(data)
    end
  end

  defp value(value) when is_binary(value) do
    if String.contains?(value, ": ") do
      "'#{String.replace(value, "'", "''")}'"
    else
      value
    end
  end

  defp value(value), do: to_string(value)

  defp handle_keyword_list(data, level, indent?) do
    data
    |> Enum.map_reduce(indent?, fn {key, value}, indent? ->
      indentation =
        if indent? do
          String.duplicate("  ", level)
        else
          ""
        end

      {delimiter, string_value} =
        case value do
          [] ->
            {"", ""}

          value when is_list(value) ->
            {"\n", to_yml(value, level + 1, true)}

          value ->
            {" ", to_yml(value, level + 1, false)}
        end

      {"#{indentation}#{key}:#{delimiter}#{string_value}", true}
    end)
    |> elem(0)
    |> Enum.join(if(level == 0, do: "\n\n", else: "\n"))
  end
end
