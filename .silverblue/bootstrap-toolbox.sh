#!/usr/bin/env bash

set -euo pipefail

# Executed on the host

export BOX_RELEASE_VERSION="42"

echo -e "\e[34mRemoving existing container fedora-toolbox-$BOX_RELEASE_VERSION...\e[0m"
toolbox rm --force "fedora-toolbox-$BOX_RELEASE_VERSION" || true

echo -e "\e[34mCreating new container fedora-toolbox-$BOX_RELEASE_VERSION...\e[0m"
toolbox create \
  --assumeyes \
  --distro fedora \
  --release "$BOX_RELEASE_VERSION"

toolbox run --distro fedora --release "$BOX_RELEASE_VERSION" bash < "$(dirname "$0")/exec-inside-toolbox.sh"
