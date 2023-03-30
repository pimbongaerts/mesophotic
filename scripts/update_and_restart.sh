#!/bin/bash
set -e
set -o pipefail

SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
RAILS_ENV=${RAILS_ENV:-production}

pushd "$SCRIPT_DIR"/..
git pull
bin/bundle install
bin/rails assets:precompile
bin/bundle exec whenever --update-crontab
touch tmp/restart.txt
popd
