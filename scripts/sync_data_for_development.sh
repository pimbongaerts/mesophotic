#!/bin/bash
set -e
set -o pipefail

SCRIPT_DIR="${BASH_SOURCE[0]%/*}"
DATA_DIR=${1:-"$SCRIPT_DIR/.."}

mkdir -p "$DATA_DIR"/db
rsync -ralP mesophotic:mesonew/db/production.sqlite3 "$DATA_DIR"/db/development.sqlite3
rsync -ralP mesophotic:mesonew/storage "$DATA_DIR"
