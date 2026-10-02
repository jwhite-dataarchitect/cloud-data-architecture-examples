# Dockerfile for RClone ingestion container
# Day 4: security hardening + execution defaults
#
# Base image is pinned to an immutable digest (reproducible builds, supply-chain
# protection). To update: bump the tag, then refresh the digest with
#   docker buildx imagetools inspect rclone/rclone:<new-tag>
# and replace the sha256 below.

FROM rclone/rclone:1.75.1@sha256:45401ad7410db1d67ffdb58e19059ad20b0d8e0285a60e38bbec55cc1019c7a5

# Install bash for better scripting
RUN apk add --no-cache bash

# Create non-root user for runtime
RUN adduser -D -u 1000 rclone-user

# Copy scripts
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Config template path (Cloud Build mounts real config here)
ENV RCLONE_CONFIG="/config/rclone.conf"

# Switch to non-root
USER rclone-user
WORKDIR /workspace

# Healthcheck: verify rclone binary works
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["rclone", "version"]

# Default entrypoint runs the sync script; override with --entrypoint for rclone commands
ENTRYPOINT ["/scripts/sync-data.sh"]
CMD ["--help"]
