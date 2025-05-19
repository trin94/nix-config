#!/usr/bin/env bash

# Executed on the host
echo -e "\e[34mBootstrapping nix-box (1/3)...\e[0m"

distrobox-enter --name nix-box -- bash < "$(dirname "$0")/run-1-2-nix-box-bootstrap-b.sh"
