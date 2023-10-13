#!/bin/sh

NIXPKGS_ALLOW_INSECURE=1 nix-shell -p ruby_2_7 bundler sqlite bundix --run 'bundle lock && bundix --ruby=ruby_2_7'
