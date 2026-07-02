#!/usr/bin/env bash
#
# No-op. skills/assets is a symlink to assets/. The canonical files live in one
# place. Run this if the symlink is missing (e.g. after a git checkout on a
# filesystem that doesn't support symlinks).
#
# If you need to recreate: ln -s ../assets skills/assets

set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -L "skills/assets" ] && [ ! -d "skills/assets" ]; then
  ln -s ../assets skills/assets
  echo "Created skills/assets -> ../assets"
elif [ -L "skills/assets" ]; then
  echo "skills/assets symlink OK"
else
  echo "skills/assets exists as a directory — it should be a symlink."
  echo "Remove it and run: ln -s ../assets skills/assets"
  exit 1
fi
