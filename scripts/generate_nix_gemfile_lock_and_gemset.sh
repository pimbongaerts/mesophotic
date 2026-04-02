#!/usr/bin/env sh

NIXPKGS_ALLOW_INSECURE=1 \
nix-shell \
  --run 'bundle lock && bundix --ruby=ruby-3.2' \
  --impure
