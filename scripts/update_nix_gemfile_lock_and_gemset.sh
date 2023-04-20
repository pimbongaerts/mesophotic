#!/bin/sh

nix-shell -p ruby_2_7 bundler sqlite bundix --run 'bundle update && bundix --ruby=ruby_2_7'
