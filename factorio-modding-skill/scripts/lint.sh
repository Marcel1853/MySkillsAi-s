#!/usr/bin/env bash
# Lua-Linter wie in VS Code: lua-language-server --check mit den Factorio-Typen der Erweiterung
# „Factorio Modding Tool Kit“ (FMTK). Zeigt nur Warnungen/Fehler.
#
# Aufruf: lint.sh MOD_DIR [UNTERORDNER]   z. B. lint.sh . scripts
#   LLS=/pfad/zu/lua-language-server  (Standard: aus der VS-Code-Erweiterung sumneko.lua)
#   FMTK_LIB=/pfad/zu/.../sumneko-3rd/factorio/library  (Standard: neuester aus workspaceStorage)
set -euo pipefail

MOD_DIR="$(cd "$1" && pwd)"
TARGET="$MOD_DIR/${2:-}"
LLS="${LLS:-$(ls -d "$HOME"/.vscode/extensions/sumneko.lua-*/server/bin/lua-language-server 2>/dev/null | sort -V | tail -1)}"
FMTK_LIB="${FMTK_LIB:-$(ls -td "$HOME"/.config/Code/User/workspaceStorage/*/justarandomgeek.factoriomod-debug/sumneko-3rd/factorio/library 2>/dev/null | head -1)}"
[ -x "$LLS" ] || { echo "lua-language-server nicht gefunden (LLS setzen)." >&2; exit 1; }
[ -d "$FMTK_LIB" ] || { echo "FMTK-Typen nicht gefunden (Mod-Ordner einmal in VS Code mit FMTK öffnen oder FMTK_LIB setzen)." >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
# Lua.*-Einstellungen aus .vscode/settings.json übernehmen, Bibliothek ergänzen
python3 - "$MOD_DIR" "$FMTK_LIB" "$TMP/luarc.json" <<'PY'
import json, os, sys
mod, lib, out = sys.argv[1:]
cfg = {}
p = os.path.join(mod, ".vscode", "settings.json")
if os.path.exists(p):
    try:
        cfg = {k: v for k, v in json.load(open(p)).items() if k.startswith("Lua.") and k != "Lua.workspace.userThirdParty"}
    except Exception:
        pass
cfg["Lua.workspace.library"] = [os.path.join(lib, d) for d in ("runtime", "runtime-api", "core", "base", "lua")]
cfg.setdefault("Lua.runtime.version", "Lua 5.2")
cfg["Lua.runtime.builtin"] = {"io": "disable", "os": "disable", "coroutine": "disable"}
json.dump(cfg, open(out, "w"), indent=1)
PY
# lua-language-server hält „--“ im Pfad für eine Option und bricht ab → Ziel dann umkopieren
CHECK="$TARGET"
case "$TARGET" in *--*) CHECK="$TMP/target"; cp -r "$TARGET" "$CHECK" ;; esac
"$LLS" --check="$CHECK" --configpath="$TMP/luarc.json" --checklevel=Warning --logpath="$TMP/log" 2>&1 \
  | sed 's/\x1b\[[0-9;]*m//g' | grep -E "\[(Warning|Error)\]|problems found|no problems" || true
