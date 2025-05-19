#!/usr/bin/env bash

# Executed on the host

echo -e "\e[34mRemoving existing 'fedora-box' container...\e[0m"
distrobox rm -f fedora-box || true

echo -e "\e[34mCreating new 'fedora-box' container...\e[0m"
distrobox create \
  --name fedora-box \
  --image quay.io/fedora/fedora-toolbox:42 \
  --volume /var/home/nix-store:/nix:ro \
  --hostname container-fedora-box \
  --additional-packages "ansible python3-pip" \
  --pull \
  --yes
