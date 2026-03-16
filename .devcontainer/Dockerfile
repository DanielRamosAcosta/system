FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        just \
        age \
    && rm -rf /var/lib/apt/lists/*


# watchexec
RUN curl -Lo watchexec.tar.xz https://github.com/watchexec/watchexec/releases/download/v2.3.2/watchexec-2.3.2-aarch64-unknown-linux-gnu.tar.xz \
    && tar -xJf watchexec.tar.xz \
    && install -o root -g root -m 0755 ./watchexec-2.3.2-aarch64-unknown-linux-gnu/watchexec /usr/local/bin/watchexec \
    && rm -rf watchexec.tar.xz watchexec

USER vscode

# nix
RUN curl --proto '=https' --tlsv1.2 -sSfL https://nixos.org/nix/install | sh -s -- --no-daemon \
    && mkdir -p /home/vscode/.config/nix \
    && echo 'experimental-features = nix-command flakes' >> /home/vscode/.config/nix/nix.conf \
    && echo '. /home/vscode/.nix-profile/etc/profile.d/nix.sh' >> /home/vscode/.bashrc

# Install nixos-rebuild globally via Nix
RUN export USER=vscode \
    && . /home/vscode/.nix-profile/etc/profile.d/nix.sh \
    && nix profile install nixpkgs#nixos-rebuild
