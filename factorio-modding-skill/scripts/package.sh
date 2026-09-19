#!/usr/bin/env bash
# Packt eine Factorio-Mod als <name>_<version>.zip nach <mod>/dist/ – ohne Entwicklungsdateien.
# Aufruf: package.sh [MOD_DIR]   (Standard: Ordner über diesem Script, z. B. <mod>/tools/package.sh)
# Braucht: jq, rsync, zip.
set -euo pipefail

MOD_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
NAME="$(jq -r .name "$MOD_DIR/info.json")"
VERSION="$(jq -r .version "$MOD_DIR/info.json")"
PACKAGE="${NAME}_${VERSION}"
DIST="$MOD_DIR/dist"
ZIP="$DIST/$PACKAGE.zip"

WARN_BYTES=200000000   # eigene Warnschwelle
LIMIT_BYTES=262100000  # Grenze des Mod-Portals (Stand 2026)

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# Im Zip muss der Ordner <name>_<version> heißen.
rsync -a \
  --exclude '.git/' --exclude '.gitignore' --exclude '.github/' --exclude '.vscode/' \
  --exclude 'docs/' --exclude 'tools/' --exclude 'dist/' \
  --exclude 'CLAUDE.md' --exclude '*.zip' \
  "$MOD_DIR/" "$STAGE/$PACKAGE/"

mkdir -p "$DIST"
rm -f "$ZIP"
(cd "$STAGE" && zip -qr9 "$ZIP" "$PACKAGE")

SIZE=$(stat -c %s "$ZIP")
echo "Gepackt: $ZIP ($((SIZE / 1000)) KB)"
if (( SIZE > LIMIT_BYTES )); then
  echo "FEHLER: größer als das Limit des Mod-Portals." >&2
  rm -f "$ZIP"; exit 1
elif (( SIZE > WARN_BYTES )); then
  echo "WARNUNG: über 200 MB – Grafiken in eine eigene Mod auslagern." >&2
fi
