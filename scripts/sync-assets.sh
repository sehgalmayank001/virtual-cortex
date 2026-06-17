#!/usr/bin/env bash
#
# Mirror the canonical assets/ into skills/assets/ so the AI setup skills
# (virtual-cortex-setup, graph-init) ship with the same hub pages, templates,
# and config as the manual route.
#
# The bundle keeps two copies on purpose:
#   - assets/         canonical, used by the manual setup (dropped into pages/)
#   - skills/assets/  travels with `cp -r skills/*` so the skills are self-contained
#
# Run this whenever you change anything under assets/.

set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -d "assets" ]; then
  echo "error: assets/ not found, run this from inside the bundle." >&2
  exit 1
fi

rm -rf "skills/assets"
cp -R "assets" "skills/assets"

echo "Synced assets/ -> skills/assets/"
