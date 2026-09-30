#!/usr/bin/env bash
# Spiel mit eigenem Mod-Satz starten, ohne die normale Mod-Liste anzufassen – z. B. für eine Mod,
# die sich mit Space Age nicht verträgt. Eigener Mod- und Datenordner; fremde Mods werden aus
# MODS_SOURCE nur verlinkt. Das Spiel startet im Hintergrund (Steam startet es mal direkt, mal
# nach einer Freigabe neu – ein Script, das auf das Ende wartet, hinge sonst).
# Aufruf: play-with-mods.sh MOD_DIR "modA modB …" [MOD_NAME/SZENARIO]
#   DISABLE="space-age quality elevated-rails recycler"   diese abschalten
#   WORK=~/.cache/<name>   Arbeitsordner (bleibt erhalten: Spielstände, Log, Bilder)
#   LOCALE=de              Sprache des Spiels
set -euo pipefail
MOD_DIR="$(cd "$1" && pwd)"; EXTRA="$2"; SCENARIO="${3:-}"
FACTORIO="${FACTORIO:-factorio}"; MODS_SOURCE="${MODS_SOURCE:-$HOME/.factorio/mods}"
WORK="${WORK:-$HOME/.cache/play-$(basename "$MOD_DIR")}"
mkdir -p "$WORK/mods" "$WORK/data"
ln -sfn "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"
names="base $(basename "$MOD_DIR")"
for name in $EXTRA; do
  src="$(ls -d "$MODS_SOURCE/${name}_"[0-9]* "$MODS_SOURCE/$name" 2>/dev/null | sort -V | tail -1 || true)"
  if [ -z "$src" ]; then echo "fehlt in $MODS_SOURCE: $name"; exit 1; fi
  ln -sfn "$(realpath "$src")" "$WORK/mods/$(basename "$src")"
  names="$names $name"
done
{ printf '{"mods":['; sep=""
  for name in $names; do printf '%s{"name":"%s","enabled":true}' "$sep" "$name"; sep=","; done
  for name in ${DISABLE:-}; do printf ',{"name":"%s","enabled":false}' "$name"; done
  printf ']}\n'; } > "$WORK/mods/mod-list.json"
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n[general]\nlocale=%s\n' \
  "$WORK" "${LOCALE:-en}" > "$WORK/config.ini"
rm -f "$WORK/data/factorio-current.log"
if [ -n "$SCENARIO" ]; then
  "$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --load-scenario "$SCENARIO" > "$WORK/run.log" 2>&1 &
else
  "$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" > "$WORK/run.log" 2>&1 &
fi
echo "Factorio startet (Steam fragt evtl. nach einer Freigabe). Log: $WORK/data/factorio-current.log"
