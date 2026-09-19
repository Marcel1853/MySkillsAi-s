#!/usr/bin/env bash
# Bilder für die Mod-Seite MIT Grafik aufnehmen (öffnet ein Factorio-Fenster!).
# Eigener Datenordner – Einstellungen, Spielstände und mod-list.json des Spielers bleiben unberührt.
#
# Aufruf: screenshots.sh MOD_DIR HELPER_DIR ZIEL_ORDNER [SZENARIO]
#   SZENARIO z. B. "my-mod/My-Scenario" (sonst neue Karte über --load-scenario base/freeplay)
#   FACTORIO=/pfad/zu/factorio
#
# Sicherheitsregeln (teuer gelernt):
#   * Es wird NICHTS gelöscht. Jedes fertige Bild wird sofort nach ZIEL_ORDNER kopiert.
#   * Kopiert wird erst, wenn die Datei vollständig ist (Größe stabil), sonst sind JPGs kaputt.
#   * Das Script beendet KEINE Prozesse. Das Steam-Factorio startet sich über Steam neu;
#     pkill/kill -9 mit Muster kann Editor, Steam oder die eigene Shell treffen.
#     → Am Ende das Factorio-Fenster selbst schließen.
set -euo pipefail

MOD_DIR="$(cd "$1" && pwd)"
HELPER="$(cd "$2" && pwd)"
DEST="$3"
SCENARIO="${4:-base/freeplay}"
FACTORIO="${FACTORIO:-factorio}"
MODS_SOURCE="${MODS_SOURCE:-$HOME/.factorio/mods}"

WORK="${WORK:-$HOME/.cache/factorio-shots}"
mkdir -p "$WORK/mods" "$WORK/data" "$DEST"
ln -sfn "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"
rm -rf "$WORK/mods/$(basename "$HELPER")" && cp -r "$HELPER" "$WORK/mods/"
for dep in $(jq -r '.dependencies[]? // empty' "$MOD_DIR/info.json" | grep -v '^[?!(~+]' | awk '{print $1}'); do
  case "$dep" in base|space-age|quality|elevated-rails) continue ;; esac
  src=$(ls -d "$MODS_SOURCE/${dep}_"* 2>/dev/null | sort -V | tail -1 || true)
  [ -n "$src" ] && ln -sfn "$src" "$WORK/mods/$(basename "$src")"
done
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n[general]\nlocale=en\n' "$WORK" > "$WORK/config.ini"

OUT="$WORK/data/script-output/shots"
RUN="$(date +%Y%m%d-%H%M%S)"   # neue Läufe überschreiben nichts: Unterordner je Lauf im Ziel
mkdir -p "$DEST/$RUN"

nohup "$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --load-scenario "$SCENARIO" \
  --window-size 1920x1080 --disable-audio > "$WORK/run.log" 2>&1 &

copy_ready() {
  [ -d "$OUT" ] || return 0
  for f in "$OUT"/*.jpg; do
    [ -e "$f" ] || continue
    local target="$DEST/$RUN/$(basename "$f")"
    [ -e "$target" ] && continue
    local a b; a=$(stat -c %s "$f"); sleep 1; b=$(stat -c %s "$f")
    [ "$a" = "$b" ] && [ "$a" -gt 0 ] && cp "$f" "$target" && echo "gesichert: $target"
  done
}

for _ in $(seq 1 180); do
  sleep 5
  copy_ready
  [ -f "$OUT/done.txt" ] && break
done
sleep 3; copy_ready
echo "Fertig. Bilder in $DEST/$RUN – das Factorio-Fenster jetzt bitte selbst schließen."
