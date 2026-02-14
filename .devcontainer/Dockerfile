FROM mcr.microsoft.com/devcontainers/php:8.4

USER root

# --- Install Docker CLI + Compose plugin (client only) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
  && install -m 0755 -d /etc/apt/keyrings \
  && curl -fsSL https://download.docker.com/linux/debian/gpg \
     | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
  && chmod a+r /etc/apt/keyrings/docker.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
     https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
     > /etc/apt/sources.list.d/docker.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
     docker-ce-cli \
     docker-buildx-plugin \
     docker-compose-plugin \
  && rm -rf /var/lib/apt/lists/*

# --- Use host docker daemon via socket ---
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Host daemon is Docker 24.x (max API 1.43), container CLI is newer -> pin API
ENV DOCKER_API_VERSION=1.43

# Ensure env is present in login shells
RUN printf '%s\n' \
  'export DOCKER_HOST=unix:///var/run/docker.sock' \
  'export DOCKER_API_VERSION=1.43' \
  > /etc/profile.d/docker-env.sh

# --- Prevent Apache from starting (it fails binding to :80 in devcontainers) ---
RUN mkdir -p /etc/service/apache2 \
  && touch /etc/service/apache2/down

USER vscode

