# Plan: Compliance Framework Agent GitHub Action

We will build a GitHub Action that wraps the `ghcr.io/compliance-framework/agent` Docker image. This action will allow users to run the Compliance Framework Agent within their CI/CD pipelines, configuring it dynamically via Action inputs.

## Components

1.  **`Dockerfile`**
    *   **Challenge**: The upstream image `ghcr.io/compliance-framework/agent` uses `gcr.io/distroless/base-debian12`, which does not contain a shell (`sh` or `bash`). This prevents us from running an `entrypoint.sh` script directly if we just `FROM` it.
    *   **Solution**: Use a multi-stage build.
        *   Stage 1 (`source`): `FROM ghcr.io/compliance-framework/agent` to get the binary.
        *   Stage 2 (`final`): `FROM debian:bookworm-slim` (contains `bash` and standard tools).
        *   Copy the `/app/concom` binary from `source` to `final`.
        *   Install `ca-certificates` (required for API calls).
        *   Add `entrypoint.sh`.
    *   Sets `ENTRYPOINT` to `entrypoint.sh`.

2.  **`entrypoint.sh`**
    *   **Purpose**: Generate the agent configuration file (`config.yaml`) from Action inputs and run the agent.
    *   **Logic**:
        *   Validate inputs (e.g., ensure `daemon` is not enabled implicitly or explicitly).
        *   Construct `config.yaml` with:
            *   `daemon: false` (Hardcoded for CI/CD context)
            *   `api`: derived from `api_url` input.
            *   `plugins`: injected from the `plugins` input (YAML/JSON string).
            *   `verbosity`: derived from `verbosity` input (optional).
    *   **Validation**:
        *   Ensure `api_url` is provided.
        *   Ensure `plugins` configuration is provided.
    *   **Execution**:
        *   Run the agent with the generated config: `agent --config /path/to/generated/config.yaml`

3.  **`action.yml`**
    *   **Inputs**:
        *   `api_url`: (Required) URL of the Compliance Framework API.
        *   `plugins`: (Required) YAML/JSON string defining the plugins to run.
        *   `verbosity`: (Optional) Log verbosity level (0-2).
    *   **Runs**: Uses the `Dockerfile` in the repository.

## detailed `entrypoint.sh` Logic

The script will use basic shell commands (like `echo`, `cat`) to construct the YAML file to avoid heavy dependencies, assuming the base image is minimal (likely Alpine or similar).

```bash
# ... validation ...

cat <<EOF > config.yaml
daemon: false
verbosity: ${INPUT_VERBOSITY:-0}
api:
  url: "${INPUT_API_URL}"
plugins:
${INPUT_PLUGINS}
EOF

# ... run agent ...
```

## Validation Check
*   The script will explicitly set `daemon: false` in the config, overriding any potential user intent to run as a daemon, satisfying the requirement to "check that daemon mode is off" (by enforcing it).

## Next Steps
1.  Create `Dockerfile`.
2.  Create `entrypoint.sh` and make it executable.
3.  Create `action.yml`.
