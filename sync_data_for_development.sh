#!/bin/bash
set -e
set -o pipefail

rsync -ralP mesophotic:mesonew/db/production.sqlite3 db/development.sqlite3
rsync -ralP mesophotic:mesonew/storage .
