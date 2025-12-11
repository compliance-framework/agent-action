#!/bin/bash
set -e

# Validation
if [ -z "$INPUT_API_URL" ]; then
  echo "Error: 'api_url' input is required."
  exit 1
fi

if [ -z "$INPUT_PLUGINS" ]; then
  echo "Error: 'plugins' input is required."
  exit 1
fi

# Helper to indent the plugins content
INDENTED_PLUGINS=$(echo "$INPUT_PLUGINS" | sed 's/^/  /')

# Construct config.yaml
# We manually construct the yaml to ensure structure.
# Daemon is hardcoded to false as per requirements.
cat <<EOF > /config.yaml
daemon: false
verbosity: ${INPUT_VERBOSITY:-0}
api:
  url: "${INPUT_API_URL}"
plugins:
${INDENTED_PLUGINS}
EOF

echo "Generated config.yaml content:"
cat /config.yaml

# Run agent
echo "Starting Compliance Framework Agent..."
# We assume 'concom' is in the PATH (e.g. /usr/local/bin/concom)
exec concom agent --config /config.yaml
