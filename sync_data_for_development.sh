#!/bin/bash
set -e
set -o pipefail

scp mesophotic:mesonew/db/production.sqlite3 db/development.sqlite3
rsync -ralP mesophotic:mesonew/public/system public
rsync -ralP mesophotic:mesonew/publications/pdfs publications
