FROM python:3.12-slim

# Install basic tools including bash-completion
RUN apt-get update && apt-get install -y \
    git \
    bash-completion \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

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
