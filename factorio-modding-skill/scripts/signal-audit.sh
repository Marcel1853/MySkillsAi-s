#!/usr/bin/env bash
# Prüft die Zugsignale eines Spielstands headless (nichts wird verändert, eigener Datenordner):
#   * normale Signale vor einem Knoten (Weiche/Einmündung/Kreuzung) → sollten Kettensignale sein
#   * Blöcke hinter normalen Signalen, die kürzer als der längste Zug sind
#   * doppelte Signale (kein Wagen passt dazwischen)
# Fundstellen als [gps=x,y,surface] – im Spiel in den Chat kopieren, dann springt die Karte hin.
#
# Aufruf: signal-audit.sh SPIELSTAND.zip [MIN_LAENGE] [OBERFLAECHE]
#   MIN_LAENGE: längster Zug in Feldern, Richtwert 7 je Teil (Standard 35 = Lok + 4 Wagen)
#   MODS="pfad/mod1 pfad/mod2"  Mods, die der Spielstand braucht (sonst entfernt Factorio ihre Entities)
#   FACTORIO=/pfad/zu/factorio  (Standard: factorio im PATH)
set -euo pipefail

SAVE="$(realpath "$1")"
MIN="${2:-35}"
SURFACE="${3:-}"
FACTORIO="${FACTORIO:-factorio}"
HERE="$(cd "$(dirname "$0")" && pwd)"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/mods" "$WORK/data/saves"
cp -r "$HERE/templates/signal-audit-mod" "$WORK/mods/signal-audit_0.0.1"
{
  echo "return {"
  echo "  min_length = $MIN,"
  [ -n "$SURFACE" ] && echo "  surface = \"$SURFACE\","
  echo "}"
} > "$WORK/mods/signal-audit_0.0.1/audit-config.lua"
for mod in ${MODS:-}; do
  src="$(realpath "$mod")"
  if [ -d "$src" ]; then
    # Ordner müssen wie der Mod heißen (name aus info.json), sonst lädt Factorio sie nicht
    ln -s "$src" "$WORK/mods/$(jq -r .name "$src/info.json")"
  else
    ln -s "$src" "$WORK/mods/"
  fi
done
cp "$SAVE" "$WORK/data/saves/audit.zip"
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n' "$WORK" > "$WORK/config.ini"

# Ein Tick reicht: beim Laden kommt der Prüf-Mod neu hinzu, sein on_init prüft alles.
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --benchmark "$WORK/data/saves/audit.zip" \
  --benchmark-ticks 1 > "$WORK/out.txt" 2>&1 || true
LOG="$WORK/data/factorio-current.log"
grep -o "\[SIGNALS\].*" "$LOG" || { echo "Keine [SIGNALS]-Zeilen – Log:"; grep -A8 "Error" "$LOG" | head -20; exit 1; }
