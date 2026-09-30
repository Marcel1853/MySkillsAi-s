#!/usr/bin/env bash
# Szenario-Script ohne Spieler auf Lade- und Syntaxfehler prüfen: startet einen Headless-Server mit
# dem Szenario, wartet TIMEOUT Sekunden, sucht im Log nach Fehlern. on_player_created kommt dabei
# NICHT (kein Spieler) – was ein Szenario erst für einen Spieler baut, prüft nur ein grafischer Lauf.
# Aufruf: scenario-check.sh MOD_DIR MOD_NAME/SZENARIO [TIMEOUT]
set -uo pipefail
MOD_DIR="$(cd "$1" && pwd)"; SCENARIO="$2"; TIMEOUT="${3:-60}"
FACTORIO="${FACTORIO:-factorio}"; MODS_SOURCE="${MODS_SOURCE:-$HOME/.factorio/mods}"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK/mods" "$WORK/data"
ln -s "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"
for dep in ${DEPS:-}; do
  src="$(ls -d "$MODS_SOURCE/${dep}_"[0-9]* "$MODS_SOURCE/$dep" 2>/dev/null | sort -V | tail -1 || true)"
  [ -n "$src" ] && ln -s "$(realpath "$src")" "$WORK/mods/"
done
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n' "$WORK" > "$WORK/config.ini"
timeout "$TIMEOUT" "$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" \
  --start-server-load-scenario "$SCENARIO" --port 34299 > "$WORK/server.txt" 2>&1
# nur echte Fehler – „Got EOF on stdin“ ist normal (keine Konsole angeschlossen)
PATTERN="Error while (loading|running)|Failed to load mod|non-recoverable|Missing required dependency|doesn't contain key"
if grep -qE "$PATTERN" "$WORK/server.txt"; then
  grep -E -A6 "$PATTERN" "$WORK/server.txt" | head -12; exit 1
fi
grep -q "Hosting game" "$WORK/server.txt" && echo "Szenario lädt ohne Fehler: $SCENARIO"
