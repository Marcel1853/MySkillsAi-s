#!/usr/bin/env python3
"""Blaupausen-Text (aus dem Spiel kopiert, beginnt mit „0“) in eine Lua-Tabelle umwandeln, die ein
Szenario oder Testmod mit create_entity baut – schneller und vorhersehbarer als build_blueprint.

Aufruf: blueprint2lua.py <blaupause.txt> <ziel.lua>
Ergebnis: return { { name = "...", x = …, y = …, dir = … }, … }  (dir fehlt, wenn 0)
Reihenfolge: Stützen und Rampen, Hochgleise, Gleise, dann alles Übrige – Signale und Haltestellen
brauchen ihr Gleis, Hochgleise ihre Stütze. Kabel (wires) und Einstellungen (tags, control_behavior)
gehen dabei verloren: im Script neu verbinden bzw. setzen.
Verschieben nur um GERADE Beträge (Gleise liegen auf ungeraden Koordinaten).
"""
import base64, json, sys, zlib

FIRST = ["rail-support", "rail-ramp"]


def rank(name):
    if name in FIRST:
        return 0
    if name.startswith("elevated-"):
        return 1
    if name.endswith("-rail") or "rail-a" in name or "rail-b" in name:
        return 2
    return 3


def number(value):
    text = "%g" % value
    return "0" if text == "-0" else text


def main(src, dst):
    data = json.loads(zlib.decompress(base64.b64decode(open(src).read().strip()[1:])))
    entities = data["blueprint"].get("entities", [])
    entities.sort(key=lambda e: (rank(e["name"]), e.get("entity_number", 0)))
    lines = ["-- erzeugt mit blueprint2lua.py aus " + src, "return {"]
    for e in entities:
        pos = e["position"]
        extra = ", dir = %d" % e["direction"] if e.get("direction") else ""
        lines.append('  { name = "%s", x = %s, y = %s%s },' % (e["name"], number(pos["x"]), number(pos["y"]), extra))
    lines.append("}")
    open(dst, "w").write("\n".join(lines) + "\n")
    print("%d Objekte → %s" % (len(entities), dst))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
