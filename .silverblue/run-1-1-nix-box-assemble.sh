#!/usr/bin/env bash

# Executed on the host

echo -e "\e[34mRemoving existing 'nix-box' container...\e[0m"
distrobox rm -f nix-box || true

echo -e "\e[34mCreating new 'nix-box' container...\e[0m"
distrobox create \
  --name nix-box \
  --image quay.io/fedora/fedora-toolbox:42 \
  --volume /var/home/nix-store:/nix \
  --hostname container-nix-box \
  --pull \
  --yes \
  --no-entry \
