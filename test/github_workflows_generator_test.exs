defmodule GithubWorkflowsGeneratorTest do
  use ExUnit.Case
  doctest GithubWorkflowsGenerator

  test "greets the world" do
    assert GithubWorkflowsGenerator.hello() == :world
  end
end
