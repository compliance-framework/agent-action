# Stage 1: Get the binary from the upstream agent image, pinned to an agent release.
# ccf-bump rewrites this line when compliance-framework/agent releases.
FROM ghcr.io/compliance-framework/agent:0.9.5 AS source

# Stage 2: Final image. Distroless Debian 13 with glibc (the agent binary is dynamically linked),
# CA certificates for the API and registry calls, and the busybox shell of the debug tag for
# entrypoint.sh. No package manager and no other userland.
FROM gcr.io/distroless/base-debian13:debug@sha256:864c3a9f9e4718b65712bbf0ebc2c1a001ff1a3c3b80cece822532d8dc67b0bf

# Copy binary from the source stage
COPY --from=source /app/concom /usr/local/bin/concom

# Copy entrypoint. The image has no /bin/sh: busybox's sh runs it.
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/busybox/sh", "/entrypoint.sh"]
