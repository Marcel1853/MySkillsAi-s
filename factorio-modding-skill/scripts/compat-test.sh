#!/usr/bin/env bash
# Headless-Test zusammen mit anderen Mods (z. B. Kompatibilität mit einer Schiffs- oder
# Weltraum-Mod). Die fremden Mods werden aus MODS_SOURCE nur VERLINKT, nie verändert.
#
# Aufruf: compat-test.sh MOD_DIR TESTMOD_DIR "modA modB …" [TICKS] [KENNUNG]
#   Mod-Namen ohne Version; genommen wird die neueste Zip bzw. der Ordner in MODS_SOURCE.
#   DISABLE="space-age quality elevated-rails recycler"  schaltet DLC/Mods ab (eigene mod-list.json),
#   nötig für Mods, die sich mit Space Age nicht vertragen.
#   FACTORIO=/pfad/zu/factorio, MODS_SOURCE=~/.factorio/mods
set -euo pipefail
MOD_DIR="$(cd "$1" && pwd)"; TEST_DIR="$(cd "$2" && pwd)"; EXTRA="$3"
TICKS="${4:-36000}"; TAG="${5:-SELFTEST}"
FACTORIO="${FACTORIO:-factorio}"; MODS_SOURCE="${MODS_SOURCE:-$HOME/.factorio/mods}"
WORK="$(mktemp -d)"; trap '[ -n "${KEEP:-}" ] || rm -rf "$WORK"' EXIT
mkdir -p "$WORK/mods" "$WORK/data"
ln -s "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"
cp -r "$TEST_DIR" "$WORK/mods/"
for name in $EXTRA; do
  src="$(ls -d "$MODS_SOURCE/${name}_"[0-9]* "$MODS_SOURCE/$name" 2>/dev/null | sort -V | tail -1 || true)"
  if [ -z "$src" ]; then echo "fehlt in $MODS_SOURCE: $name"; exit 1; fi
  ln -s "$(realpath "$src")" "$WORK/mods/$(basename "$src")"
done
if [ -n "${DISABLE:-}" ]; then
  { printf '{"mods":[{"name":"base","enabled":true}'
    for name in $DISABLE; do printf ',{"name":"%s","enabled":false}' "$name"; done
    printf ']}\n'; } > "$WORK/mods/mod-list.json"
fi
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n' "$WORK" > "$WORK/config.ini"
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --create "$WORK/test.zip" > /dev/null
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --benchmark "$WORK/test.zip" \
  --benchmark-ticks "$TICKS" | grep -E "avg:|Error" || true
LOG="$WORK/data/factorio-current.log"
grep -o "\[$TAG\].*" "$LOG" || true
grep -E -A6 "Error while (loading|running)|Failed to load mod|Missing required dependency" "$LOG" | head -8 || true
if grep -qE "\[$TAG\] FAIL|Error while|Failed to load mod|Missing required dependency" "$LOG"; then exit 1; fi
