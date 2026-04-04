#!/usr/bin/env sh

# Update all gems in Gemfile.lock and regenerate gemset.nix.
# Copies Gemfile to /tmp to bypass Nix frozen mode, then runs bundix.

set -e
cd "$(dirname "$0")/.."

nix develop --command bash -c "
  cp Gemfile /tmp/Gemfile.mesophotic
  cp Gemfile.lock /tmp/Gemfile.mesophotic.lock 2>/dev/null || true
  cd /tmp
  BUNDLE_GEMFILE=Gemfile.mesophotic bundle update
  cp Gemfile.mesophotic.lock $(pwd)/Gemfile.lock
"

bundix
