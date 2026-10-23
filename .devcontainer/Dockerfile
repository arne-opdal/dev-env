FROM python:3.12-slim

# Install basic tools including bash-completion
# libatomic1 is required by the Node.js binary pre-commit downloads for markdownlint
RUN apt-get update && apt-get install -y \
    git \
    bash-completion \
    ca-certificates \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Trust the IKTNH root CA (required behind SSL inspection)
COPY iktnhRootCa.crt /usr/local/share/ca-certificates/iktnhRootCa.crt
RUN update-ca-certificates

# Make Python (pip, requests, certifi users) and Node (VS Code server/extensions)
# use the system trust store instead of their bundled CA lists
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    PIP_CERT=/etc/ssl/certs/ca-certificates.crt \
    CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt \
    NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/iktnhRootCa.crt

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/bash \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME

# Add .local/bin to PATH for user-installed Python packages
RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> /home/$USERNAME/.bashrc

WORKDIR /workspace
