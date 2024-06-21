defmodule GithubWorkflowsGenerator.YmlEncoderTest do
  use ExUnit.Case, async: true

  alias GithubWorkflowsGenerator.YmlEncoder

  describe "encode/1" do
    test "encodes a list" do
      assert YmlEncoder.encode([:pull_request, :push]) == """
             - pull_request
             - push
             """
    end

    test "encodes a multiline string" do
      assert YmlEncoder.encode(path: "_build\ndeps") == """
             path: |
               _build
               deps
             """
    end

    test "encodes a list of lists" do
      assert YmlEncoder.encode(on: [pull_request: [], push: [branches: ["main"]]]) == """
             on:
               pull_request:
               push:
                 branches:
                   - main
             """
    end

    test "encodes a complex data structure" do
      assert YmlEncoder.encode(
               on: [
                 schedule: [
                   [cron: "30 5 * * 1,3"],
                   [cron: "30 5 * * 2,4"]
                 ]
               ],
               jobs: [
                 test_schedule: [
                   "runs-on": "ubuntu-latest",
                   steps: [
                     [
                       name: "Not on Monday or Wednesday",
                       if: "github.event.schedule != '30 5 * * 1,3'",
                       run: "echo \"This step will be skipped on Monday and Wednesday\""
                     ],
                     [
                       name: "Every time",
                       run: "echo \"This step will always run\""
                     ],
                     [
                       uses: "actions/cache@v3",
                       with: [
                         path: "_build\ndeps",
                         key:
                           "mix-${{ matrix.versions.runner-image }}-${{ matrix.versions.otp }}-${{ matrix.versions.elixir }}-${{ github.sha }}",
                         "restore-keys": "\nmix-${{ matrix.versions.runner-image }}"
                       ]
                     ]
                   ]
                 ]
               ]
             ) ==
               """
               on:
                 schedule:
                   - cron: 30 5 * * 1,3
                   - cron: 30 5 * * 2,4

               jobs:
                 test_schedule:
                   runs-on: ubuntu-latest
                   steps:
                     - name: Not on Monday or Wednesday
                       if: github.event.schedule != '30 5 * * 1,3'
                       run: echo "This step will be skipped on Monday and Wednesday"
                     - name: Every time
                       run: echo "This step will always run"
                     - uses: actions/cache@v3
                       with:
                         path: |
                           _build
                           deps
                         key: mix-${{ matrix.versions.runner-image }}-${{ matrix.versions.otp }}-${{ matrix.versions.elixir }}-${{ github.sha }}
                         restore-keys: |
                           mix-${{ matrix.versions.runner-image }}
               """
    end
  end
end
