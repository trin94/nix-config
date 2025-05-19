#!/usr/bin/env bash

# Executed on the host
echo -e "\e[34mBootstrapping fedora-box (1/2)...\e[0m"

distrobox-enter --name fedora-box -- bash < "$(dirname "$0")/run-2-2-fedora-box-bootstrap-b.sh"
