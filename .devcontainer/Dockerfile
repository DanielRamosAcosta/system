FROM mcr.microsoft.com/devcontainers/base:debian

# Instalar dependencias necesarias para nix
RUN apt-get update && apt-get install -y curl sudo bash && rm -rf /var/lib/apt/lists/*

# Crear usuario 'dani'
RUN useradd -m -s /bin/bash dani && \
    echo 'dani ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Instalar Nix sin daemon como dani
USER dani
ENV USER=dani
WORKDIR /home/dani

# Instala Nix en el perfil del usuario
RUN curl -L https://nixos.org/nix/install | bash -s -- --no-daemon

# Activa flakes y nix-command
RUN mkdir -p /home/dani/.config/nix && \
    echo 'experimental-features = nix-command flakes' >> /home/dani/.config/nix/nix.conf && \
    mkdir -p /home/dani/.ssh && \
    chown dani:dani /home/dani/.ssh && \
    chmod 700 /home/dani/.ssh

# Entorno y PATH
ENV NIX_CONF_DIR=/home/dani/.config/nix
ENV SHELL=/bin/bash
ENV PATH=/home/dani/.nix-profile/bin:$PATH

WORKDIR /workspace
