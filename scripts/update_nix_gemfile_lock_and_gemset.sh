#!/usr/bin/env sh

# Update all gems in Gemfile.lock and regenerate gemset.nix.
# Uses Ruby from nixpkgs (same as flake) without the frozen bundlerEnv wrapper.
#
# Unsets GEM_PATH / RUBYLIB so the dev shell's bundlerEnv (compiled against a
# different ruby derivation hash) doesn't leak into the nix shell subshell
# and cause native-extension incompatibility errors.

set -e
cd "$(dirname "$0")/.."

unset GEM_PATH GEM_HOME RUBYLIB BUNDLE_GEMFILE

BUNDLER_VERSION="$(awk '/^BUNDLED WITH/{getline; gsub(/^[ \t]+/, ""); print}' Gemfile.lock)"

nix shell nixpkgs#ruby_3_4 --command sh -c "
  gem install --no-document bundler -v ${BUNDLER_VERSION} >/dev/null
  bundle _${BUNDLER_VERSION}_ lock --update
"

bundix
