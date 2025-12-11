# Stage 1: Get the binary from the upstream agent image
# We use the 'latest' tag or a specific version if needed. 
# Since the user didn't specify, we'll assume we want to pull the latest available image or specific tag.
# Ideally we should pin this, but for this task "already available" implies latest or a known tag.
FROM ghcr.io/compliance-framework/agent:0.2 AS source

# Stage 2: Final image with shell
FROM debian:bookworm-slim

# Install ca-certificates for SSL connections
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy binary from the source stage
COPY --from=source /app/concom /usr/local/bin/concom

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
