#!/usr/bin/env sh

# Generate Gemfile.lock, gemset.nix and gemset-platforms.nix from the current Gemfile.
# Uses Ruby from nixpkgs (same as flake) without the frozen bundlerEnv wrapper.

set -e
cd "$(dirname "$0")/.."

# Every Ruby platform the flake builds for. Gemfile.lock lists exactly these, so
# precompiled gems get a variant per platform and no host-specific platform
# (such as arm64-darwin-25) leaks in.
PLATFORMS="arm64-darwin x86_64-darwin x86_64-linux aarch64-linux"

ruby_shell() {
  nix shell nixpkgs#ruby_3_4 --command "$@"
}

ruby_shell bundle lock
ruby_shell bundle lock --add-platform $PLATFORMS

locked=$(awk '/^PLATFORMS$/ { p = 1; next } p && /^$/ { exit } p { print $1 }' Gemfile.lock)
extra=""
for platform in $locked; do
  case " $PLATFORMS " in
    *" $platform "*) ;;
    *) extra="$extra $platform" ;;
  esac
done
if [ -n "$extra" ]; then
  ruby_shell bundle lock --remove-platform $extra
fi

# Runs bundix from nixpkgs so this works when the dev shell itself is broken.
nix shell nixpkgs#bundix --command bundix

# bundix records one hash per gem, so precompiled gems get their variants'
# hashes from a separate file that flake.nix picks from per system.
ruby_shell ruby scripts/generate_gemset_platforms.rb
