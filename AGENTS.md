# Dotfiles

Home Manager flake for Elias's machines: Fedora Atomic hosts plus one Mac. Not NixOS: only user-level config lives
here.

## Where to start

* `flake.nix` maps each host to its file under `setups/`.
* Programs are modules under `setups/programs/`, off until a host enables them. `just add-program <name>` scaffolds
  one.
* Every `.nix` file under `setups/programs/` is imported as a module, so helpers and scripts use another extension.

## Checks

* `just verify` builds the current host. Green means done.
* `just apply` and `just update` switch the live profile; leave them to Elias.

## Agent config

The opencode program holds Elias's global agent rules and skills, not this repo's. Edit them here; deployed copies
are read-only until `just apply`. Skills adapted from upstream keep their line layout for diffing.

## Commits

Scope is the host or program touched: `feat(fish): ...`.
