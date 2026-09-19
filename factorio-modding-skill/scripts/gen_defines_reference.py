#!/usr/bin/env python3
"""
Erzeugt references/09-defines.md direkt aus der offiziellen API-Seite
https://lua-api.factorio.com/latest/defines.html – damit keine erfundenen Werte
im Skill stehen. Handgeschriebene, geprüfte Hinweise stehen in NOTES unten.

Aufruf: python3 gen_defines_reference.py [ausgabe.md]
        (Standard: ../references/09-defines.md relativ zu diesem Script)
Optional: DEFINES_HTML=/pfad/zu/defines.html (statt Download)
"""
import html
import os
import re
import sys
import urllib.request
from datetime import date

URL = "https://lua-api.factorio.com/latest/defines.html"

# Geprüfte Hinweise zu Tabellen, die oft falsch benutzt werden (Stand 2.1.19).
NOTES = {
    "events": "Build/Remove per Script heißen `script_raised_built`, `script_raised_destroy`, "
              "`script_raised_revive`, `script_raised_set_tiles` (ohne `on_`). Event-Daten stehen je Event "
              "auf https://lua-api.factorio.com/latest/events.html – z. B. liefert `on_train_changed_state` "
              "nur `train` und `old_state` (neuer Zustand = `train.state`).",
    "inventory": "Maschinen nutzen seit 2.0 die gemeinsamen `crafter_*`-Inventare "
                 "(`crafter_input`, `crafter_output`, `crafter_modules`, `crafter_trash`) – die alten "
                 "`assembling_machine_*`/`furnace_*` gibt es nicht mehr.",
    "wire_connector_id": "Damit holt man Netze (`entity.get_circuit_network(id)`) und verbindet Kabel "
                         "(`entity.get_wire_connector(id, true).connect_to(...)`). Ein `defines.circuit_connector` gibt es nicht.",
    "wire_type": "Nur noch als Eigenschaft (z. B. `LuaCircuitNetwork.wire_type`), nicht als Parameter von "
                 "`get_circuit_network`.",
    "train_state": "Ein `path_lost` gibt es nicht; „kein Weg“ ist `no_path`.",
    "space_platform_state": "Angekommen = `waiting_at_station`, unterwegs = `on_the_path`.",
    "control_behavior": "Enthält nur Unter-Tabellen für einzelne Entity-Typen; Einstellungen wie „aktivieren/"
                        "deaktivieren“ stehen am jeweiligen `Lua*ControlBehavior`-Objekt, nicht in defines.",
}

MISSING = """## Häufig erfunden – gibt es NICHT als defines

| Oft geschrieben | Richtig |
|---|---|
| `defines.comparator.less` usw. | Vergleiche sind Text: `"<"`, `">"`, `"="`, `"≥"`/`">="`, `"≤"`/`"<="`, `"≠"`/`"!="` (ComparatorString) |
| `defines.quality.*` | Qualitäten sind Prototypen: `prototypes.quality["rare"]`, in Signalen/Items per Name `quality = "rare"` |
| `defines.surface_property.*` | Oberflächen-Eigenschaften sind Prototypen: `prototypes.surface_property["gravity"]`, Wert: `surface.get_property("gravity")` |
| `defines.circuit_connector.*` | `defines.wire_connector_id.*` |
| `defines.events.on_script_raised_built` | `defines.events.script_raised_built` |
| `defines.inventory.assembling_machine_input`, `furnace_source` | `defines.inventory.crafter_input` usw. |
| `defines.train_state.path_lost` | `defines.train_state.no_path` |
"""


def fetch():
    path = os.environ.get("DEFINES_HTML")
    if path:
        return open(path, encoding="utf-8").read()
    with urllib.request.urlopen(URL) as r:
        return r.read().decode("utf-8")


def clean(fragment):
    text = html.unescape(re.sub(r"<[^>]+>", " ", fragment))
    text = re.sub(r"\s+", " ", text).strip()
    text = text.replace("[...]", "").strip()
    # nur der erste Satz, damit die Tabelle lesbar bleibt
    m = re.match(r"(.{0,220}?[.!?])(\s|$)", text)
    return (m.group(1) if m else text[:220]).replace("|", "\\|")


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                                             "..", "references", "09-defines.md")
    page = fetch()
    version = re.search(r"Version\s+(\d+\.\d+\.\d+)", html.unescape(re.sub(r"<[^>]+>", " ", page)))
    version = version.group(1) if version else "?"
    entries = {}  # tabelle -> [(voller name, beschreibung)]
    for m in re.finditer(r'<td class="td-modif" id="(defines\.[a-z_0-9.]+)">.*?</td>\s*<td[^>]*>(.*?)</td>',
                         page, re.S):
        full, desc = m.group(1), clean(m.group(2))
        parts = full.split(".")
        if len(parts) < 3:
            continue
        entries.setdefault(parts[1], []).append((full, desc))
    tables = sorted(set(entries) | set(re.findall(r'id="defines\.([a-z_0-9]+)"', page)))

    lines = [
        "# Factorio API: defines (aus der offiziellen Doku erzeugt)",
        "",
        f"> **Automatisch erzeugt** mit `scripts/gen_defines_reference.py` aus {URL}",
        f"> (API-Version {version}, Stand {date.today().isoformat()}). Nicht von Hand ergänzen – neu erzeugen.",
        "> Hinweise zu oft falsch benutzten Tabellen stehen jeweils direkt unter der Überschrift.",
        "",
        MISSING,
        "## Inhalt",
        "",
        " · ".join(f"[{t}](#defines{t})" for t in tables),
        "",
    ]
    for t in tables:
        lines += [f"## defines.{t}", ""]
        if t in NOTES:
            lines += [f"> {NOTES[t]}", ""]
        rows = entries.get(t, [])
        if rows:
            lines += ["| Wert | Bedeutung |", "|---|---|"]
            lines += [f"| `{full}` | {desc} |" for full, desc in rows]
        else:
            lines.append("_(nur Unter-Tabellen oder ohne Einträge – siehe offizielle Doku)_")
        lines.append("")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"{out}: {len(tables)} Tabellen, {sum(len(v) for v in entries.values())} Werte (API {version})")


if __name__ == "__main__":
    main()
