# Stage 1: Get the binary from the upstream agent image, pinned to an agent release.
# ccf-bump rewrites this line when compliance-framework/agent releases.
FROM ghcr.io/compliance-framework/agent:0.9.5 AS source

# Stage 2: Final image. Distroless Debian 13 "static": CA certificates for the API and registry
# calls and the busybox shell of the debug tag for entrypoint.sh. No glibc, package manager or
# other userland. No libc is needed: concom is built with CGO_ENABLED=0 (statically linked,
# agent >= 0.9.5), and the plugins it downloads and runs are CGO_ENABLED=0 static binaries too.
FROM gcr.io/distroless/static-debian13:debug@sha256:6a5e9a4921c51d613ab8128402badf19d27b16627f92f97146f4597d2c593104

# Copy binary from the source stage
COPY --from=source /app/concom /usr/local/bin/concom

# Copy entrypoint. The image has no /bin/sh: busybox's sh runs it.
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/busybox/sh", "/entrypoint.sh"]
