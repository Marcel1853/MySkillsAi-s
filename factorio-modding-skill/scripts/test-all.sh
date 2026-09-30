#!/usr/bin/env bash
# Alle Prüfungen auf einmal: Lint je Ordner, dann die Headless-Tests PARALLEL (jeder Test legt
# seinen eigenen mktemp-Datenordner an, das geht gleichzeitig). Gezählt wird nur die Ausgabe
# dieses Laufs – nie alte Ergebnisdateien. Eine Zeile je Prüfung, Exit 1 bei einem Fehler.
#
# Aufruf (im Mod-Ordner):  path/to/skill/scripts/test-all.sh
#   LINT_DIRS="scripts prototypes tools"             Ordner für den Lint (Standard)
#   TESTS="tools/selftest.sh:SELFTEST tools/compat.sh:COMPAT"
#       Testscript:Kennung – das Script gibt Zeilen „[KENNUNG] PASS …“/„[KENNUNG] FAIL …“ aus
#       und endet bei Fehlern mit Exit ≠ 0.
# Im Projekt UTL: Lint + drei Headless-Tests in gut einer Minute statt drei.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
LINT="$HERE/lint.sh"
OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT
failed=0

pids=()
for entry in ${TESTS:-}; do
  script="${entry%%:*}"; tag="${entry##*:}"
  "$script" > "$OUT/$tag.txt" 2>&1 & pids+=("$!:$tag:$script")
done

for dir in ${LINT_DIRS:-scripts prototypes tools}; do
  [ -d "$dir" ] || continue
  "$LINT" . "$dir" 2>&1 | tr '\r' '\n' > "$OUT/lint-$dir.txt"
  if grep -q "no problems found" "$OUT/lint-$dir.txt"; then
    echo "Lint $dir: sauber"
  else
    echo "Lint $dir: $(grep -c '\[Warning\]\|\[Error\]' "$OUT/lint-$dir.txt") Befunde"
    grep '\[Warning\]\|\[Error\]' "$OUT/lint-$dir.txt" | head -10 | sed 's/^/    /'
    failed=1
  fi
done

for item in "${pids[@]}"; do
  pid="${item%%:*}"; rest="${item#*:}"; tag="${rest%%:*}"; script="${rest#*:}"
  wait "$pid"; code=$?
  pass=$(grep -c "\[$tag\] PASS" "$OUT/$tag.txt" || true)
  fail=$(grep -c "\[$tag\] FAIL" "$OUT/$tag.txt" || true)
  if [ "$code" -eq 0 ] && [ "$fail" -eq 0 ] && [ "$pass" -gt 0 ]; then
    echo "$script: $pass bestanden"
  else
    echo "$script: $pass bestanden, $fail FEHLER (Exit $code)"
    grep "\[$tag\] FAIL\|Error" "$OUT/$tag.txt" | head -10 | sed 's/^/    /'
    failed=1
  fi
done
exit $failed
