#!/bin/bash
set -e
set -o pipefail

nix-shell -p ruby_2_7 bundler bundix --run 'bundle lock && bundix --ruby=ruby_2_7'
