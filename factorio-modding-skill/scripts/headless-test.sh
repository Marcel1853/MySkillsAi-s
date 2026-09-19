#!/usr/bin/env bash
# Startet Factorio headless mit eigenem Datenordner (Spieler-Einstellungen bleiben unberührt,
# läuft auch bei offenem Spiel): Mod + Testmod, neue Karte, N Ticks, dann Ergebnisse.
#
# Aufruf: headless-test.sh MOD_DIR TESTMOD_DIR [TICKS]
#   FACTORIO=/pfad/zu/factorio  (Standard: factorio im PATH)
#   MODS_SOURCE=~/.factorio/mods  (dort liegen die Abhängigkeiten als Zip oder Ordner)
# Der Testmod schreibt Zeilen „[SELFTEST] PASS …“ / „[SELFTEST] FAIL …“ per log().
set -euo pipefail

MOD_DIR="$(cd "$1" && pwd)"
TEST_DIR="$(cd "$2" && pwd)"
TICKS="${3:-3600}"
FACTORIO="${FACTORIO:-factorio}"
MODS_SOURCE="${MODS_SOURCE:-$HOME/.factorio/mods}"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/mods" "$WORK/data"
ln -s "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"
cp -r "$TEST_DIR" "$WORK/mods/"

# Pflicht-Abhängigkeiten der Mod verlinken (ohne base/space-age, ohne ? ! ( ) ~ +)
for dep in $(jq -r '.dependencies[]? // empty' "$MOD_DIR/info.json" | grep -v '^[?!(~+]' | awk '{print $1}'); do
  case "$dep" in base|space-age|quality|elevated-rails) continue ;; esac
  src=$(ls -d "$MODS_SOURCE/${dep}_"* 2>/dev/null | sort -V | tail -1 || true)
  if [ -n "$src" ]; then ln -s "$src" "$WORK/mods/"; else echo "Abhängigkeit fehlt: $dep" >&2; fi
done

printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n' "$WORK" > "$WORK/config.ini"
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --create "$WORK/test.zip" > /dev/null
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --benchmark "$WORK/test.zip" \
  --benchmark-ticks "$TICKS" > /dev/null || true

LOG="$WORK/data/factorio-current.log"
grep -o "\[SELFTEST\].*" "$LOG" || echo "Keine [SELFTEST]-Zeilen – Log prüfen."
grep -A8 "Error" "$LOG" | head -20 || true
echo "PASS: $(grep -c '\[SELFTEST\] PASS' "$LOG" || true)  FAIL: $(grep -c '\[SELFTEST\] FAIL' "$LOG" || true)"
