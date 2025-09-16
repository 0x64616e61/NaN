FROM nixos/nix:latest

# Enable experimental features for flakes
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Copy the droid configuration
COPY droid/configuration.nix /config/configuration.nix

# Build the NixOS system
RUN nix-build '<nixpkgs/nixos>' \
    -A system \
    -I nixos-config=/config/configuration.nix \
    --option sandbox false

# Set up the environment
ENV PATH="/run/current-system/sw/bin:$PATH"

# Create user home directory
RUN mkdir -p /home/a

# Set working directory
WORKDIR /home/a

# Use zsh as the default shell
CMD ["/run/current-system/sw/bin/zsh"]