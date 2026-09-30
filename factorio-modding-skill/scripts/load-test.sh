#!/usr/bin/env bash
# Lasttest: Testmod baut in on_init eine große Welt (viele Objekte der eigenen Mod), dann misst ein
# Headless-Benchmark die Zeit je Tick. Ausgabe: Schnitt, Median, 99 %, Max für Gesamt und Script
# (= alle Mods), Ticks unter 60 UPS und die größten Script-Spitzen.
# Aufruf: load-test.sh MOD_DIR TESTMOD_DIR [TICKS] [WARMUP]
#   Standard 36000 Ticks (10 Minuten Spielzeit), die ersten 600 zählen nicht.
#   Vergleich mit einer älteren Version: dasselbe mit einer git-worktree-Kopie (Ordnername = Mod-Name)
#   parallel laufen lassen – beide teilen sich dann die CPU, die Zahlen sind etwas verrauscht.
set -euo pipefail
MOD_DIR="$(cd "$1" && pwd)"; TEST_DIR="$(cd "$2" && pwd)"
TICKS="${3:-36000}"; WARM="${4:-600}"
FACTORIO="${FACTORIO:-factorio}"; MODS_SOURCE="${MODS_SOURCE:-$HOME/.factorio/mods}"
WORK="$(mktemp -d)"; trap '[ -n "${KEEP:-}" ] || rm -rf "$WORK"' EXIT
mkdir -p "$WORK/mods" "$WORK/data"
ln -s "$MOD_DIR" "$WORK/mods/$(basename "$MOD_DIR")"
cp -r "$TEST_DIR" "$WORK/mods/"
for dep in ${DEPS:-}; do
  src="$(ls -d "$MODS_SOURCE/${dep}_"[0-9]* "$MODS_SOURCE/$dep" 2>/dev/null | sort -V | tail -1 || true)"
  [ -n "$src" ] && ln -s "$(realpath "$src")" "$WORK/mods/"
done
printf '[path]\nread-data=__PATH__executable__/../../data\nwrite-data=%s/data\n' "$WORK" > "$WORK/config.ini"
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --create "$WORK/load.zip" > "$WORK/create.txt" 2>&1 \
  || { grep -A8 Error "$WORK/create.txt" | head -20; exit 1; }
"$FACTORIO" -c "$WORK/config.ini" --mod-directory "$WORK/mods" --benchmark "$WORK/load.zip" \
  --benchmark-ticks "$TICKS" --benchmark-verbose all > "$WORK/timings.txt"
if grep -q "Error while" "$WORK/data/factorio-current.log"; then grep -A6 "Error while" "$WORK/data/factorio-current.log" | head; exit 1; fi
python3 - "$WORK/timings.txt" "$WARM" <<'PY'
import sys, statistics
rows, header = [], None
for line in open(sys.argv[1]):
    line = line.strip()
    if line.startswith("tick,"):
        header = line.split(",")
    elif header and line.startswith("t") and "," in line:
        parts = line.split(",")
        rows.append({h: parts[i] for i, h in enumerate(header) if i < len(parts)})
warm = int(sys.argv[2])
def col(name):
    return [int(r[name]) / 1e6 for r in rows if r.get(name, "").isdigit()]  # ns → ms
print(f"Ticks gemessen: {len(rows)} (erste {warm} ausgelassen)")
print(f"{'Bereich':<14}{'Schnitt':>10}{'Median':>10}{'99 %':>10}{'Max':>10}   (ms pro Tick)")
for name, label in (("wholeUpdate", "Gesamt"), ("scriptUpdate", "Script")):
    v = col(name)[warm:]
    if not v: continue
    s = sorted(v)
    print(f"{label:<14}{statistics.mean(v):>10.3f}{statistics.median(v):>10.3f}{s[int(len(s)*0.99)]:>10.3f}{s[-1]:>10.3f}")
v = col("wholeUpdate")[warm:]
print(f"Ticks über 16,67 ms (unter 60 UPS): {sum(1 for x in v if x > 16.67)}")
s = col("scriptUpdate")
top = sorted(range(len(s)), key=lambda i: -s[i])[:5]
print("Größte Script-Spitzen (Tick: ms):", ", ".join(f"{rows[i]['tick']}: {s[i]:.2f}" for i in top))
PY
