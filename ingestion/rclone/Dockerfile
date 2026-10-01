FROM rclone/rclone:latest

# Install bash for better scripting
RUN apk add --no-cache bash

# Copy our scripts into the container
COPY scripts/ /scripts/

# Make scripts executable
RUN chmod +x /scripts/*.sh

# Set working directory
WORKDIR /workspace

# Default command shows help
CMD ["rclone", "--help"]