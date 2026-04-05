#!/usr/bin/env sh

# Update all gems in Gemfile.lock and regenerate gemset.nix.
# Uses Ruby from nixpkgs (same as flake) without the frozen bundlerEnv wrapper.

set -e
cd "$(dirname "$0")/.."

nix shell nixpkgs#ruby_3_4 --command bundle update

bundix
