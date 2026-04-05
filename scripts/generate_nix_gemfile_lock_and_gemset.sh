#!/usr/bin/env sh

# Generate Gemfile.lock and gemset.nix from the current Gemfile.
# Uses Ruby from nixpkgs (same as flake) without the frozen bundlerEnv wrapper.

set -e
cd "$(dirname "$0")/.."

nix shell nixpkgs#ruby_3_4 --command bundle lock

bundix
