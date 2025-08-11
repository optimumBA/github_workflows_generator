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

    test "encodes a multiline string with colons correctly" do
      assert YmlEncoder.encode(example: "this: is valid\nanother: line") == """
             example: |
               this: is valid
               another: line
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
                   services: [
                     db: [
                       image: "postgres:13",
                       ports: ["5432:5432"],
                       env: [POSTGRES_PASSWORD: "postgres"],
                       options:
                         "--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5"
                     ]
                   ],
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
                     ],
                     [
                       name: "Create an environment",
                       run:
                         "read token_id token_secret webhook_secret < <(echo $(curl -X POST \"http://localhost/api/environments\" -H \"Content-Type: application/json; charset=utf-8\" -H \"Authorization: ApiKey ${{ secrets.API_KEY }}\" -d '{\"name\": \"pr-${{ github.event.number }}\"}' | jq -r '.token_id, .token_secret, .webhook_secret')) && echo \"TOKEN_ID=$token_id\" >> credentials && echo \"TOKEN_SECRET=$token_secret\" >> credentials && echo \"WEBHOOK_SECRET=$webhook_secret\" >> credentials && cat credentials >> $GITHUB_ENV\"\""
                     ],
                     [
                       name: "Delete an environment",
                       run:
                         "curl -X DELETE \"http://localhost/api/environments/1\" -H \"Content-Type: application/json; charset=utf-8\" -H \"Authorization: ApiKey ${{ secrets.API_KEY }}\""
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
                   services:
                     db:
                       image: postgres:13
                       ports:
                         - 5432:5432
                       env:
                         POSTGRES_PASSWORD: postgres
                       options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
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
                     - name: Create an environment
                       run: 'read token_id token_secret webhook_secret < <(echo $(curl -X POST "http://localhost/api/environments" -H "Content-Type: application/json; charset=utf-8" -H "Authorization: ApiKey ${{ secrets.API_KEY }}" -d ''{"name": "pr-${{ github.event.number }}"}'' | jq -r ''.token_id, .token_secret, .webhook_secret'')) && echo "TOKEN_ID=$token_id" >> credentials && echo "TOKEN_SECRET=$token_secret" >> credentials && echo "WEBHOOK_SECRET=$webhook_secret" >> credentials && cat credentials >> $GITHUB_ENV""'
                     - name: Delete an environment
                       run: 'curl -X DELETE "http://localhost/api/environments/1" -H "Content-Type: application/json; charset=utf-8" -H "Authorization: ApiKey ${{ secrets.API_KEY }}"'
               """
    end
  end
end
