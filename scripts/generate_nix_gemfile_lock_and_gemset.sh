#!/usr/bin/env sh

NIXPKGS_ALLOW_INSECURE=1 \
nix-shell \
  --run 'bundle lock && bundix --ruby=ruby-2.7' \
  --impure
