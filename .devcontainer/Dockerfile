FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        just \
        age \
    && rm -rf /var/lib/apt/lists/*


# kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# helm
RUN curl -LO https://get.helm.sh/helm-v3.17.4-linux-arm64.tar.gz \
    && tar -zxvf helm-v3.17.4-linux-arm64.tar.gz \
    && install -o root -g root -m 0755 linux-arm64/helm /usr/local/bin/helm \
    && rm -rf linux-arm64 helm-v3.17.4-linux-arm64.tar.gz

# tanka
RUN curl -Lo tk https://github.com/grafana/tanka/releases/latest/download/tk-linux-amd64 \
    && install -o root -g root -m 0755 tk /usr/local/bin/tk \
    && rm tk

# jsonnet-bundler
RUN curl -Lo jb https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v0.6.0/jb-linux-arm64 \
    && install -o root -g root -m 0755 jb /usr/local/bin/jb \
    && rm jb

# jsonnet-language-server
RUN curl -Lo jsonnet-language-server https://github.com/grafana/jsonnet-language-server/releases/download/v0.16.0/jsonnet-language-server_0.16.0_linux_arm64 \
    && install -o root -g root -m 0755 jsonnet-language-server /usr/local/bin/jsonnet-language-server \
    && rm jsonnet-language-server

# jsonnet-debugger
RUN curl -Lo jsonnet-debugger https://github.com/grafana/jsonnet-debugger/releases/download/v0.1.0/jsonnet-debugger_0.1.0_linux_arm64 \
    && install -o root -g root -m 0755 jsonnet-debugger /usr/local/bin/jsonnet-debugger \
    && rm jsonnet-debugger

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
