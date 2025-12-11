# Compliance Framework Agent Action

This GitHub Action runs the Compliance Framework Agent to check policies against your infrastructure configuration. It allows you to run compliance checks directly within your CI/CD pipelines.

## Usage

```yaml
name: Compliance Check
on: [push]

jobs:
  compliance:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Run Compliance Agent
        uses: compliance-framework/agent-action@v0
        with:
          api_url: 'https://your-compliance-framework.url.com'
          verbosity: '1'
          plugins: |
            local-ssh-security:
              source: ghcr.io/compliance-framework/plugin-ssh:latest
              config:
                host: "localhost"
              policies:
                - ghcr.io/compliance-framework/policy-ssh-baseline:latest
```

## Inputs

| Input | Description | Required | Default |
| --- | --- | --- | --- |
| `api_url` | The URL of the Compliance Framework API where results will be reported. | **Yes** | N/A |
| `plugins` | A YAML formatted string defining the plugins to run. This corresponds to the `plugins` section of the agent configuration file. | **Yes** | N/A |
| `verbosity` | Log verbosity level. `0` (Info), `1` (Debug), or `2` (Trace). | No | `0` |

## Outputs

This action provides no outputs.

## Example: running multiple plugins

You can configure multiple plugins in the `plugins` input block:

```yaml
- uses: compliance-framework/agent-action@v0
  with:
    api_url: 'https://your-compliance-framework.url.com'
    plugins: |
      ssh-check:
        source: ghcr.io/compliance-framework/plugin-ssh:latest
        config:
          target: "prod-server-1"
      
      k8s-check:
        source: ghcr.io/compliance-framework/plugin-k8s:latest
        config:
          kubeconfig: "/path/to/kubeconfig"
```

## How it works

This action:
1.  Takes your inputs and generates a `config.yaml` file on the fly.
2.  Ensures the agent runs in non-daemon mode (`daemon: false`).
3.  Executes the agent inside a Docker container to perform the compliance checks.
