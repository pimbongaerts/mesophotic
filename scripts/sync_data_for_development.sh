#!/bin/bash
set -e
set -o pipefail

SCRIPT_DIR="${BASH_SOURCE[0]%/*}"

rsync -ralP mesophotic:mesonew/db/production.sqlite3 "$SCRIPT_DIR"/../db/development.sqlite3
rsync -ralP mesophotic:mesonew/storage "$SCRIPT_DIR"/..
